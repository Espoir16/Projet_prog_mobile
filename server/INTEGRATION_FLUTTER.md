# 📱 Intégration Flutter - Interroger les rappels

## 🎯 Comment Flutter utilise PocketBase pour les rappels

Après qu'on scanne un code-barres, on vérifie si ce produit est rappelé.

---

## 1️⃣ Setup Flutter (PocketBase client)

### Package `pocketbase`

Ajoute la dépendance dans `pubspec.yaml` :

```yaml
dependencies:
  pocketbase: ^0.16.0
```

```bash
flutter pub get
```

### Initialiser le client PocketBase (dans `main.dart` ou un service)

```dart
import 'package:pocketbase/pocketbase.dart';

// Instance globale (singleton pattern)
final pb = PocketBase('http://localhost:8090');
```

**Note :** Pour la production, adapte le URL avec ton serveur PocketBase :
```dart
final pb = PocketBase('https://pocketbase.monserveur.com');
```

---

## 2️⃣ Vérifier un produit (après scan code-barres)

### Exemple : chercher un rappel par code-barres

```dart
Future<RecallProduct?> checkProductRecall(String barcode) async {
  try {
    // Requête simple : filtre sur barcode
    final records = await pb.collection('recalls').getList(
      filter: 'barcode = "$barcode"',
      limit: 1,
    );

    if (records.items.isNotEmpty) {
      final recall = records.items.first;
      
      // Construire un objet Dart
      return RecallProduct(
        barcode: recall.getStringValue('barcode'),
        productName: recall.getStringValue('product_name'),
        brand: recall.getStringValue('brand'),
        reason: recall.getStringValue('reason'),
        risk: recall.getStringValue('risk'), // 'low', 'medium', 'high'
        publicationDate: recall.getDateTimeValue('publication_date'),
        endDate: recall.getDateTimeValue('end_date'),
        distributors: recall.getStringValue('distributors'),
        geographicArea: recall.getStringValue('geographic_area'),
      );
    }
    
    return null; // Pas de rappel
  } catch (error) {
    print('Erreur vérification rappel: $error');
    return null;
  }
}
```

### Modèle Dart

```dart
class RecallProduct {
  final String barcode;
  final String productName;
  final String brand;
  final String reason;
  final String risk; // 'low', 'medium', 'high'
  final DateTime? publicationDate;
  final DateTime? endDate;
  final String distributors;
  final String geographicArea;

  RecallProduct({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.reason,
    required this.risk,
    this.publicationDate,
    this.endDate,
    required this.distributors,
    required this.geographicArea,
  });
}
```

---

## 3️⃣ Afficher le résultat dans l'UI

Après un scan, affiche un message si le produit est rappelé :

```dart
FutureBuilder<RecallProduct?>(
  future: checkProductRecall(barcodeScanned),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Erreur: ${snapshot.error}');
    }

    final recall = snapshot.data;

    if (recall == null) {
      // Pas de rappel ✅
      return Card(
        color: Colors.green[100],
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            '✓ Produit OK (pas de rappel)',
            style: TextStyle(color: Colors.green[900]),
          ),
        ),
      );
    }

    // ⚠️ Produit rappelé !
    return Card(
      color: Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ RAPPEL PRODUIT',
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('${recall.productName} (${recall.brand})'),
            Text('Raison: ${recall.reason}'),
            Text('Risque: ${recall.risk}'),
            Text('Distributeurs: ${recall.distributors}'),
            if (recall.endDate != null)
              Text('Fin du rappel: ${recall.endDate}'),
          ],
        ),
      ),
    );
  },
)
```

---

## 4️⃣ Cas d'usage avancés

### Lister tous les rappels (avec pagination)

```dart
Future<List<RecallProduct>> getAllRecalls({int page = 1, int perPage = 20}) async {
  try {
    final records = await pb.collection('recalls').getList(
      page: page,
      perPage: perPage,
      sort: '-publication_date', // Plus récents d'abord
    );

    return records.items.map((record) => RecallProduct(
      barcode: record.getStringValue('barcode'),
      productName: record.getStringValue('product_name'),
      brand: record.getStringValue('brand'),
      reason: record.getStringValue('reason'),
      risk: record.getStringValue('risk'),
      publicationDate: record.getDateTimeValue('publication_date'),
      endDate: record.getDateTimeValue('end_date'),
      distributors: record.getStringValue('distributors'),
      geographicArea: record.getStringValue('geographic_area'),
    )).toList();
  } catch (error) {
    print('Erreur récupération rappels: $error');
    return [];
  }
}
```

### Filtrer par niveau de risque

```dart
Future<List<RecallProduct>> getHighRiskRecalls() async {
  try {
    final records = await pb.collection('recalls').getList(
      filter: 'risk = "high"',
      sort: '-publication_date',
    );

    // ... même mapping que plus haut
    return [];
  } catch (error) {
    print('Erreur: $error');
    return [];
  }
}
```

### Recherche par marque

```dart
Future<List<RecallProduct>> searchByBrand(String brand) async {
  try {
    final records = await pb.collection('recalls').getList(
      filter: 'brand ~ "${brand.toLowerCase()}"', // ~ est un "contains"
    );

    // ... mapping
    return [];
  } catch (error) {
    print('Erreur: $error');
    return [];
  }
}
```

---

## 5️⃣ Subscribe aux changements (Real-time)

Si tu veux être notifié en temps réel quand les rappels changent :

```dart
pb.collection('recalls').subscribe('*', (e) {
  print('Changement: ${e.action}');
  print('Record: ${e.record!.id}');

  // Rafraîchir l'UI, notifier les utilisateurs, etc.
});
```

---

## 6️⃣ Gestion des erreurs

```dart
Future<RecallProduct?> checkProductRecallSafe(String barcode) async {
  try {
    final records = await pb.collection('recalls').getList(
      filter: 'barcode = "$barcode"',
      limit: 1,
    ).catchError((error) {
      if (error.response?.status == 404) {
        print('Collection recalls non trouvée');
      } else if (error is SocketException) {
        print('Erreur réseau - PocketBase offline?');
      } else {
        print('Erreur PocketBase: $error');
      }
      return null;
    });

    if (records == null || records.isEmpty) {
      return null;
    }

    // ... construire RecallProduct
    return null;
  } catch (e) {
    print('Erreur innattendue: $e');
    return null;
  }
}
```

---

## 7️⃣ Stockage local (cache)

Si tu veux cacher les rappels localement (offline-first) :

```dart
DART
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> cacheRecalls(List<RecallProduct> recalls) async {
  final prefs = await SharedPreferences.getInstance();
  final json = jsonEncode(
    recalls.map((r) => {...}).toList(),
  );
  await prefs.setString('cached_recalls', json);
}

Future<List<RecallProduct>> getCachedRecalls() async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('cached_recalls');
  if (json == null) return [];

  final list = jsonDecode(json) as List;
  return list.map((item) => RecallProduct.fromJson(item)).toList();
}
```

---

## 📝 Notes finales

- **URL PocketBase** : Par défaut `http://localhost:8090` en dev
  - En prod, utilise l'URL publique du serveur
  
- **Authentification** : Les rappels sont publics (List Rule = `true`)
  - Pas besoin de login pour les lire
  
- **Performance** :
  - Toujours filtrer par barcode si possible (clé unique)
  - Limiter le résultat avec `limit: 1` ou `limit: 10`
  - Éviter de charger tous les rappels à chaque fois

- **Offline** :
  - Aucune garantie hors-ligne par défaut
  - Implémente un cache local si nécessaire (voir section 7)

---

**Besoin de plus d'infos sur PocketBase Flutter SDK ?**  
Voir [https://pub.dev/packages/pocketbase](https://pub.dev/packages/pocketbase)
