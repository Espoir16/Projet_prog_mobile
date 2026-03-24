/**
 * PocketBase Hooks - Recalls Management
 * 
 * Fonctionnalités :
 * - Fetch JSON distant 2 fois par jour (6h et 18h)
 * - Upsert des rappels produits pour éviter les doublons
 * - Logs détaillés et gestion d'erreurs
 * 
 * Source JSON attendue :
 * https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/rappels_de_produits_alimentaires_v2/records (exemple)
 * 
 * Structure JSON attendue (adaptable) :
 * {
 *   "records": [
 *     {
 *       "gtin": "...",
 *       "product_name": "...",
 *       "brand": "...",
 *       "risk": "low|medium|high",
 *       ...
 *     }
 *   ]
 * }
 */

// ============================================================================
// CONFIGURATION
// ============================================================================

const RECALLS_JSON_URL = 'https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/rappels_de_produits_alimentaires_v2/records?limit=10000';
const COLLECTION_NAME = 'recalls';
const CRON_EXPRESSION = '0 6,18 * * *'; // 06:00 et 18:00 chaque jour
const IMPORT_TIMEOUT_MS = 30000; // 30 secondes max pour fetch

// Mapping des champs JSON source vers PocketBase
// Adapter si ta source JSON a des clés différentes
const FIELD_MAPPING = {
  'gtin': 'barcode',
  'product_name': 'product_name',
  'brand': 'brand',
  'motif_du_rappel': 'reason',
  'risk_level': 'risk',
  'date_de_publication': 'publication_date',
  'date_de_fin_du_rappel': 'end_date',
  'zone_geographique': 'geographic_area',
  'distributeurs': 'distributors',
  'url_source': 'source_url'
};

// ============================================================================
// FONCTIONS UTILITAIRES
// ============================================================================

/**
 * Log avec timestamp
 */
function logInfo(message) {
  console.info(`[${new Date().toISOString()}] ✓ ${message}`);
}

function logWarn(message) {
  console.warn(`[${new Date().toISOString()}] ⚠ ${message}`);
}

function logError(message, error) {
  console.error(`[${new Date().toISOString()}] ✗ ${message}`, error || '');
}

/**
 * Map les champs JSON source vers le schéma PocketBase
 */
function mapRecallRecord(jsonRecord) {
  const pbRecord = {
    barcode: null,
    product_name: '',
    brand: '',
    reason: '',
    risk: 'low', // Défaut
    publication_date: new Date().toISOString().split('T')[0],
    end_date: null,
    distributors: '',
    geographic_area: 'France',
    source_url: ''
  };

  // Parcourir le mapping et remplir les champs disponibles
  for (const [jsonKey, pbKey] of Object.entries(FIELD_MAPPING)) {
    if (jsonRecord[jsonKey] !== undefined && jsonRecord[jsonKey] !== null) {
      const value = jsonRecord[jsonKey];
      
      // Traitement spécifique selon le champ
      if (pbKey === 'risk') {
        // Normaliser le risque en lowercase
        pbRecord[pbKey] = String(value).toLowerCase();
      } else if (pbKey === 'publication_date' || pbKey === 'end_date') {
        // Parser les dates au format ISO
        pbRecord[pbKey] = value ? new Date(value).toISOString().split('T')[0] : null;
      } else {
        // Texte/string simple
        pbRecord[pbKey] = String(value).trim();
      }
    }
  }

  return pbRecord;
}

/**
 * Valide qu'un record rappel est exploitable
 */
function isValidRecall(record) {
  return record.barcode && record.barcode.length > 0;
}

/**
 * Upsert : crée ou met à jour un rappel selon son barcode
 */
async function upsertRecall(record) {
  try {
    // Chercher si le rappel existe déjà
    const existing = await $app.dao().findCollectionByNameOrId(COLLECTION_NAME);
    const records = await $app.dao().findRecordsByFilter(
      existing,
      `barcode = "${record.barcode}"`,
      '-created',
      1,
      0
    );

    if (records && records.length > 0) {
      // Update
      const existingRecord = records[0];
      existingRecord.product_name = record.product_name;
      existingRecord.brand = record.brand;
      existingRecord.reason = record.reason;
      existingRecord.risk = record.risk;
      existingRecord.publication_date = record.publication_date;
      existingRecord.end_date = record.end_date;
      existingRecord.distributors = record.distributors;
      existingRecord.geographic_area = record.geographic_area;
      existingRecord.source_url = record.source_url;

      await $app.dao().saveRecord(existingRecord);
      return { action: 'update', barcode: record.barcode };
    } else {
      // Create
      const newRecord = new Record();
      newRecord.collection = existing;
      Object.assign(newRecord, record);

      await $app.dao().saveRecord(newRecord);
      return { action: 'create', barcode: record.barcode };
    }
  } catch (error) {
    logError(`Upsert failed for barcode ${record.barcode}`, error);
    throw error;
  }
}

/**
 * Télécharge et parse le JSON distant
 */
async function fetchRecallsJSON() {
  try {
    const response = await $http.client().get(RECALLS_JSON_URL);
    if (!response || !response.statusCode) {
      throw new Error('No response from URL');
    }
    
    if (response.statusCode !== 200) {
      throw new Error(`HTTP ${response.statusCode}: ${response.error || 'Unknown error'}`);
    }

    let jsonData = {};
    try {
      jsonData = JSON.parse(response.body);
    } catch (e) {
      logError('JSON parse error', e);
      throw new Error('Invalid JSON format');
    }

    // Adapter selon la structure réelle de ta source
    // Exemple : { "records": [...] } ou { "data": [...] }
    let recalls = [];
    if (jsonData.records && Array.isArray(jsonData.records)) {
      recalls = jsonData.records;
    } else if (Array.isArray(jsonData)) {
      recalls = jsonData;
    } else {
      logWarn('Unexpected JSON structure, no records array found');
      recalls = [];
    }

    return recalls;
  } catch (error) {
    logError('Fetch recalls JSON failed', error);
    throw error;
  }
}

/**
 * Importe les rappels & upsert
 */
async function importRecalls() {
  const startTime = Date.now();
  let createdCount = 0;
  let updatedCount = 0;
  let skippedCount = 0;

  try {
    logInfo('=== Starting recalls import ===');

    // Fetch JSON distant
    logInfo('Fetching recalls JSON...');
    const jsonRecalls = await fetchRecallsJSON();
    logInfo(`Fetched ${jsonRecalls.length} recalls from source`);

    if (!jsonRecalls || jsonRecalls.length === 0) {
      logWarn('No recalls to import');
      return { created: 0, updated: 0, skipped: 0, duration_ms: Date.now() - startTime };
    }

    // Parcourir et upsert
    for (const jsonRecord of jsonRecalls) {
      try {
        // Mapper vers schéma PocketBase
        const pbRecord = mapRecallRecord(jsonRecord);

        // Valider
        if (!isValidRecall(pbRecord)) {
          skippedCount++;
          continue;
        }

        // Upsert
        const result = await upsertRecall(pbRecord);
        if (result.action === 'create') {
          createdCount++;
        } else if (result.action === 'update') {
          updatedCount++;
        }
      } catch (error) {
        logError(`Error processing recall record: ${JSON.stringify(jsonRecord).substring(0, 50)}`, error);
        skippedCount++;
      }
    }

    const duration = Date.now() - startTime;
    logInfo(`=== Import complete: ${createdCount} created, ${updatedCount} updated, ${skippedCount} skipped (${duration}ms) ===`);

    return { created: createdCount, updated: updatedCount, skipped: skippedCount, duration_ms: duration };

  } catch (error) {
    logError('Import recalls failed fatally', error);
    throw error;
  }
}

// ============================================================================
// HOOKS REGISTRATION
// ============================================================================

/**
 * Enregistre le cron job au démarrage de PocketBase
 */
onBootstrap((e) => {
  logInfo('PocketBase booting - registering recalls cron job');

  // Vérifier que la collection existe
  try {
    $app.dao().findCollectionByNameOrId(COLLECTION_NAME);
    logInfo(`Collection '${COLLECTION_NAME}' exists`);
  } catch (error) {
    logError(`Collection '${COLLECTION_NAME}' not found! Create it first.`, error);
    return;
  }

  // Enregistrer le cron job
  try {
    $app.cron().add(
      CRON_EXPRESSION,
      async () => {
        try {
          await importRecalls();
        } catch (error) {
          logError('Cron job execution failed', error);
        }
      }
    );
    logInfo(`Cron job registered: "${CRON_EXPRESSION}" (every day at 06:00 and 18:00)`);
  } catch (error) {
    logError('Failed to register cron job', error);
  }
});

/**
 * Route manuelle pour tester l'import (optionnel)
 * POST /api/collections/recalls/import
 */
onRecordBeforeCreateRequest((e) => {
  if (e.collection.name === COLLECTION_NAME && e.requestInfo?.query?.manual_import === '1') {
    // À adapter selon tes besoins - ce n'est qu'un exemple
  }
}, COLLECTION_NAME);

// ============================================================================
// FIN DES HOOKS
// ============================================================================
