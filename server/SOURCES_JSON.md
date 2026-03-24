# 🔧 Guide d'adaptation - URLs sources JSON et field mapping

## 📍 URLs de sources JSON connues

### Option 1️⃣ : Ministère de l'Économie (France) [RECOMMANDÉE]

```javascript
const RECALLS_JSON_URL = 'https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/rappels_de_produits_alimentaires_v2/records?limit=10000&order_by=date_de_publication';
```

**Structure JSON :**
```json
{
  "records": [
    {
      "gtin": "3608581077507",
      "product_name": "Petit Dej Fromage",
      "brand": "CAMEMBERT",
      "motif_du_rappel": "Présence de Listeria monocytogenes",
      "risk_level": "high",
      "date_de_publication": "2026-03-20",
      "date_de_fin_du_rappel": "2026-04-20",
      "zone_geographique": "France",
      "distributeurs": "AUCHAN, CARREFOUR",
      ...
    }
  ]
}
```

**Field Mapping (dans `pb_hooks/main.js`) :**
```javascript
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
};
```

---

### Option 2️⃣ : Open Food Facts

```javascript
const RECALLS_JSON_URL = 'https://world.openfoodfacts.org/api/v2/search?q=recalled:true&page_size=1000';
```

**Structure JSON :**
```json
{
  "products": [
    {
      "code": "3608581077507",
      "product_name": "Petit Dej Fromage",
      "brands": "CAMEMBERT",
      "warning": "Product contains Listeria",
      ...
    }
  ]
}
```

**Field Mapping (adapter) :**
```javascript
const FIELD_MAPPING = {
  'code': 'barcode',
  'product_name': 'product_name',
  'brands': 'brand',
  'warning': 'reason',
};
```

---

### Option 3️⃣ : API personnalisée (endpoint custom)

Si tu as un endpoint à toi :

```javascript
const RECALLS_JSON_URL = 'https://api.tonserveur.com/recalls/export';
```

**Adapter selon ta structure JSON.**

---

## 🛠️ Comment adapter le field mapping

### Cas 1 : Source JSON a des clés différentes

**Exemple :** ta source utilise `ean` au lieu de `gtin`

1. Ouvre `pb_hooks/main.js`
2. Trouve la section `FIELD_MAPPING` (lignes ~19-30)
3. Change :
   ```javascript
   // AVANT
   'gtin': 'barcode',

   // APRÈS
   'ean': 'barcode',
   ```
4. Redémarre PocketBase

### Cas 2 : Source a des champs extra non utiles

**C'est OK**, le mapping les ignore automatiquement.  
Seuls les champs listés dans `FIELD_MAPPING` sont importés.

### Cas 3 : Un champ JSON a un format bizarre

**Exemple :** `risk_level` contient "HIGH" (uppercase)

1. Ouvre `pb_hooks/main.js`
2. Va dans la fonction `mapRecallRecord()` (ligne ~68-ish)
3. Ajoute une transformation :
   ```javascript
   if (pbKey === 'risk') {
     // Normaliser en lowercase
     pbRecord[pbKey] = String(value).toLowerCase();
   }
   ```

### Cas 4 : Un champ JSON est une date en format custom

**Exemple :** `"2026-03-24T10:30:00Z"` au lieu de `"2026-03-24"`

Le code gère déjà ça :
```javascript
if (pbKey === 'publication_date' || pbKey === 'end_date') {
  // Parser les dates au format ISO
  pbRecord[pbKey] = value ? new Date(value).toISOString().split('T')[0] : null;
}
```

Si le format est encore différent (ex: `"24/03/2026"`), adapte :
```javascript
if (pbKey === 'publication_date' || pbKey === 'end_date') {
  if (value && typeof value === 'string') {
    // Parser custom pour format DD/MM/YYYY
    const parts = value.split('/');
    const date = new Date(parts[2], parseInt(parts[1]) - 1, parts[0]);
    pbRecord[pbKey] = date.toISOString().split('T')[0];
  }
}
```

---

## 🧪 Tester ton mapping

### 1️⃣ Vérifie que l'URL retourne du JSON valide

```bash
curl "https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/rappels_de_produits_alimentaires_v2/records?limit=1"
```

### 2️⃣ Regarde un exemple de record

Copie-colle un record JSON et compare avec ton `FIELD_MAPPING`.

### 3️⃣ Redémarre et regarde les logs

```bash
./pocketbase.exe serve
# Laisse tourner quelques secondes...
# Tu devrais voir des logs d'import
```

### 4️⃣ Vérifie dans PocketBase Admin

- Va dans Collections → recalls
- Consulte les records importés
- Vérifie que les champs sont bien remplis

---

## 🔄 Changer la source JSON

### Étape 1 : Identifie la nouvelle URL

```
https://...api-endpoint...
```

### Étape 2 : Télécharge un exemple

```bash
curl "https://..." > sample.json
```

### Étape 3 : Analyse la structure

```json
{
  "records": [ ... ]   // ← clé pour les records
}
```

ou

```json
{
  "data": [ ... ]      // ← clé different
}
```

### Étape 4 : Adapte `pb_hooks/main.js`

```javascript
// Cherche fetchRecallsJSON() ligne ~135
async function fetchRecallsJSON() {
  // Change l'URL
  const RECALLS_JSON_URL = 'la nouvelle URL';
  
  // ...
  
  // Adapte le parsing selon la structure
  if (jsonData.records && Array.isArray(jsonData.records)) {
    recalls = jsonData.records;
  } else if (jsonData.data && Array.isArray(jsonData.data)) {
    recalls = jsonData.data;
  }
  // ...
}
```

### Étape 5 : Adapte le `FIELD_MAPPING`

Compare les clés de la nouvelle source avec les champs PocketBase.

### Étape 6 : Redémarre et teste

```bash
./pocketbase.exe serve
# Laisse tourner, regarde les logs au prochain cron
```

---

## 📊 Statistiques & santé du service

Pour monitorer l'import :

### Dans les logs PocketBase

Tu verras des messages comme :
```
[2026-03-24T06:00:20.789Z] ✓ === Import complete: 50 created, 200 updated, 12 skipped (7000ms) ===
```

**Interprétation :**
- `50 created` = nouveaux rappels ajoutés
- `200 updated` = rappels existants mis à jour (barcodes) doublons)
- `12 skipped` = records sans code-barres (invalides)
- `7000ms` = temps d'exécution

### Si l'import échoue

Regarde les logs pour :
```
[...] ✗ Fetch recalls JSON failed: HTTP 404
[...] ✗ JSON parse error
[...] ✗ Upsert failed for barcode ...
```

**Solutions :**
1. Vérifie l'URL (404 = page pas trouvée)
2. Vérifie que le JSON est valide
3. Vérifie que `FIELD_MAPPING` correspond aux clés réelles
4. Augmente le timeout : `const IMPORT_TIMEOUT_MS = 60000;` (60 secondes)

---

## 🚀 Deployment en production

Quand tu déploies PocketBase en production :

1. **URL de source** : utilise une URL HTTPS stable
2. **Timeout** : augmente un peu selon la latence réseau
3. **Logs** : garde les logs, c'est utile pour debug
4. **Backup** : La base `pb_data/data.db` doit être backupée régulièrement

---

**Questions ?**  
Consulte `pb_hooks/main.js` pour plus de détails sur le code.
