# ⚡ Quick Start - Rappels Produits PocketBase

**Durée estimée :** 10 minutes

---

## 🚀 Démarrage en 5 étapes

### 1️⃣ Lance PocketBase

```bash
cd server
./pocketbase.exe serve
```

Ouvre http://localhost:8090/_/

### 2️⃣ Crée la collection `recalls`

Suis les instructions pas-à-pas dans [`COLLECTION_SETUP.md`](COLLECTION_SETUP.md)

⏱️ **Compte 3-5 min :** 10 champs à créer + rules d'accès

### 3️⃣ Configure les API Rules

Dans PocketBase Admin → Collections → recalls → API Rules :

```
List Rule:     true
View Rule:     true
Create Rule:   false
Update Rule:   false
Delete Rule:   false
```

Clique **Save**

### 4️⃣ Redémarre PocketBase et vérifie les logs

```
[...] ✓ Collection 'recalls' exists
[...] ✓ Cron job registered: "0 6,18 * * *"
```

✅ **C'est bon !**

### 5️⃣ Teste l'import manuel (optionnel)

Modifie temporairement `pb_hooks/main.js` :

```javascript
// Ligne ~14, change :
const CRON_EXPRESSION = '*/5 * * * *'; // Toutes les 5 min
```

Redémarre → attends 5 min → regarde les logs

Une fois testé, remets `'0 6,18 * * *'` (06:00 et 18:00)

---

## ✅ Checklist

- [ ] PocketBase lancé
- [ ] Collection `recalls` créée (10 champs)
- [ ] API Rules configurées (List/View = true, Create/Update/Delete = false)
- [ ] Logs affichent "Cron job registered"
- [ ] Test import manuel OK (optionnel)
- [ ] `pb_hooks/main.js` commité sur git
- [ ] `README.md` commité sur git
- [ ] `COLLECTION_SETUP.md` commité sur git
- [ ] `.gitignore` appliqué

---

## 📦 Binôme : comment cloner et utiliser

```bash
# Clone
git clone <url>
cd projet/server

# Lance PocketBase
./pocketbase.exe serve

# Va dans http://localhost:8090/_/
# Crée la collection 'recalls' (suis COLLECTION_SETUP.md)
# Configure les rules d'accès (suis cette checklist)

# C'est prêt !
```

---

## 🧪 Teste depuis Flutter

Ajoute à `pubspec.yaml` :

```yaml
pocketbase: ^0.16.0
```

```dart
import 'package:pocketbase/pocketbase.dart';

final pb = PocketBase('http://localhost:8090');

// Cherche un rappel
final results = await pb.collection('recalls').getList(
  filter: 'barcode = "3608581077507"',
);

if (results.items.isNotEmpty) {
  print('Rappel trouvé: ${results.items.first.data}');
} else {
  print('Pas de rappel');
}
```

---

## 📖 Docs complètes (si besoin)

- [`README.md`](README.md) - Vue d'ensemble & troubleshooting
- [`COLLECTION_SETUP.md`](COLLECTION_SETUP.md) - Créer la collection détail
- [`INTEGRATION_FLUTTER.md`](INTEGRATION_FLUTTER.md) - Requêtes Flutter
- [`SOURCES_JSON.md`](SOURCES_JSON.md) - Adapter la source JSON
- [`pb_hooks/main.js`](pb_hooks/main.js) - Code du cron

---

## 🆘 Problème rapide ?

| Problème | Solution |
|----------|----------|
| Cron ne s'exécute pas | Vérifie les logs, attend 06:00 ou 18:00 |
| Collection inexistante | Suis COLLECTION_SETUP.md pour la créer |
| Flutter ne peut pas lister | Vérifie List Rule = `true` dans PocketBase |
| JSON ne s'importe pas | Adapte `FIELD_MAPPING` dans `pb_hooks/main.js` |
| Pas de nouveaux rappels | Vérifie l'URL JSON source, teste avec `curl` |

---

**Prêt ?** Commence par l'étape 1 ! 🚀
