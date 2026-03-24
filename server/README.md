# 🚀 PocketBase Server - Rappels Produits

## 📖 Vue d'ensemble

Ce dossier contient le backend PocketBase pour la gestion des **rappels produits**. 

**Fonctionnement :**
- Une tâche cron s'exécute **2 fois par jour** (06:00 et 18:00)
- Elle télécharge un fichier JSON depuis une source distante
- Elle importe/met à jour les rappels dans la base de données PocketBase
- L'app Flutter peut interroger la collection `recalls` pour vérifier si un produit est rappelé

---

## 🛠️ Structure

```
server/
├── pocketbase.exe          # Binaire PocketBase
├── pb_data/                # Base de données (à gitignore)
├── pb_hooks/
│   └── main.js             # Hooks pour cron + import
├── README.md               # Ce fichier
├── .gitignore              # Fichiers à ignorer
└── COLLECTION_SETUP.md     # Instructions création collection
```

---

## 🚀 Démarrage rapide

### 1️⃣ Première utilisation (toi + binôme)

**Créer la collection `recalls` :**

1. Ouvre une console dans le dossier `server/`
2. Lance PocketBase :
   ```bash
   ./pocketbase.exe serve
   ```
3. Ouvre http://localhost:8090/_/ (interface admin)
4. **Crée la collection `recalls`** en suivant les instructions dans `COLLECTION_SETUP.md`
5. Configure les règles d'accès API (voir section ci-dessous)

**Attention :** À la première exécution, tu dois **créer la collection manuellement**.  
Une fois créée, elle sera sauvegardée dans `pb_data/data.db` et visible pour le binôme (si le fichier n'est pas gitignore).

### 2️⃣ Lancement quotidien

```bash
./pocketbase.exe serve
```

- Le serveur PocketBase démarre sur http://localhost:8090
- À 06:00 et 18:00, le cron job s'exécute automatiquement
- Les rappels sont importés/mis à jour
- Consulte les logs pour vérifier que tout fonctionne

### 3️⃣ Binôme : clone et utilise

Si tu clones le projet avec un binôme :

```bash
# Clone le repo
git clone <url> my-project
cd my-project/server

# Lance PocketBase
./pocketbase.exe serve

# C'est tout ! La collection et les hooks sont déjà configurés
```

---

## 📱 Comment Flutter interroge PocketBase

Depuis ton app Flutter, tue peux interroger les rappels :

```dart
// Exemple : chercher un rappel pour un code-barres
final results = await pb.collection('recalls').getList(
  filter: 'barcode = "$barcode"',
  limit: 1,
);

if (results.items.isNotEmpty) {
  // Le produit est rappelé !
  final recall = results.items.first;
  print('Rappel: ${recall.data['product_name']} - Raison: ${recall.data['reason']}');
} else {
  // Pas de rappel
  print('Produit OK');
}
```

---

## 🔍 Logs et diagnostic

Les logs du cron job s'affichent dans la console PocketBase :

```
[2026-03-24T06:00:00.000Z] ✓ PocketBase booting - registering recalls cron job
[2026-03-24T06:00:00.001Z] ✓ Collection 'recalls' exists
[2026-03-24T06:00:00.002Z] ✓ Cron job registered: "0 6,18 * * *"
...
[2026-03-24T06:00:15.123Z] ✓ Fetching recalls JSON...
[2026-03-24T06:00:15.456Z] ✓ Fetched 1234 recalls from source
[2026-03-24T06:00:20.789Z] ✓ === Import complete: 50 created, 200 updated, 12 skipped (7000ms) ===
```

---

## ⚙️ Configuration

### URL JSON source

Par défaut, le hook utilise :
```javascript
const RECALLS_JSON_URL = 'https://data.economie.gouv.fr/api/explore/v2.1/catalog/datasets/rappels_de_produits_alimentaires_v2/records?limit=10000';
```

**Pour changer de source :**
1. Édite `pb_hooks/main.js` (ligne ~13)
2. Change `RECALLS_JSON_URL` avec ta nouvelle source
3. Redémarre PocketBase

### Horaire du cron

Par défaut : **06:00 et 18:00** chaque jour

**Pour modifier :**
1. Édite `pb_hooks/main.js` (ligne ~14)
2. Change `CRON_EXPRESSION = '0 6,18 * * *'`
   - Exemples :
     - `'0 12 * * *'` = 12:00 (midday only)
     - `'*/30 * * * *'` = chaque 30 minutes
     - Voir [crontab.guru](https://crontab.guru) pour la syntaxe

### Mapping des champs JSON

Si ta source JSON a des champs différents :

1. Édite `pb_hooks/main.js` (lignes ~19-30)
2. Adapte le mapping `FIELD_MAPPING`
3. Exemple :
   ```javascript
   const FIELD_MAPPING = {
     'my_barcode_field': 'barcode',
     'my_product_field': 'product_name',
     ...
   };
   ```

---

## 🔐 Contrôle d'accès API

### Pour la collection `recalls`

Dans PocketBase admin, configure les **List Rules** (pour que Flutter puisse lire) :

**List Rule :**
```
// Tout le monde peut lire les rappels
true
```

ou

```
// Seuls les utilisateurs connectés
auth.isValid
```

**View Rule (pour lire un rappel individuel) :**
```
// Même que List Rule
true
```

**Create/Update/Delete Rules :**
```
// Seul le système (cron) peut créer/modifier
false
```

---

## 📦 Git & Binôme

### Fichiers à versionner

```
✅ server/pb_hooks/main.js
✅ server/README.md
✅ server/COLLECTION_SETUP.md
✅ server/.gitignore
✅ server/pocketbase.exe (optionnel, si petit)
```

### Fichiers à ignorer

```
❌ server/pb_data/data.db         (base locale)
❌ server/pb_data/auxiliary.db    (temp)
❌ server/pb_data/types.d.ts       (généré)
```

Voir `.gitignore` pour la liste complète.

### Stratégie binôme

1. **Toi** : crée la collection `recalls` et les rules d'accès dans PocketBase admin
2. **Toi** : édite les champs (si besoin) et confirme que ça fonctionne
3. **Toi** : commit et push `pb_hooks/main.js` + `README.md` + `COLLECTION_SETUP.md`
4. **Binôme** : clone, lance `pocketbase.exe serve`
5. **Binôme** : crée la même collection en suivant `COLLECTION_SETUP.md`
6. **Binôme** : configure les mêmes rules d'accès
7. **Binôme** : c'est prêt !

**Note :** Chaque développeur aura sa propre base locale (`pb_data/`), ce qui est normal et attendu pour le dev.

---

## 🐛 Troubleshooting

### Le cron ne s'exécute pas ?

1. Vérifie que PocketBase a démarré sans erreur
2. Vérifie les logs au démarrage (cron job registered ?)
3. Attends l'heure du cron (06:00 ou 18:00)
4. Consulte les logs : des messages `[Cron job execution failed]` ?

### Les rappels ne s'importent pas ?

1. Vérifie l'URL JSON source est accessible : `curl <URL>`
2. Vérifie que le JSON a la structure attendue (clés `records[]` ?)
3. Adapte `FIELD_MAPPING` dans `pb_hooks/main.js`
4. Redémarre PocketBase

### Flutter ne peut pas interroger les rappels ?

1. Vérifie que `recalls` collection existe dans PocketBase admin
2. Vérifie les **List Rules** = `true` (ou `auth.isValid`)
3. Vérifie que PocketBase écoute bien sur http://localhost:8090
4. Teste avec curl :
   ```bash
   curl "http://localhost:8090/api/collections/recalls/records/?filter=barcode%3D%228006540"
   ```

---

## 📚 Ressources

- [PocketBase Documentation](https://pocketbase.io/docs/)
- [PocketBase Hooks / JavaScript](https://pocketbase.io/docs/server-side-rules-and-filters/)
- [Cron Expression Syntax](https://crontab.guru)
- [Open Data Rappels (France)](https://data.economie.gouv.fr)

---

**Besoin d'aide ?** Consulte `COLLECTION_SETUP.md` pour les étapes de création de collection.
