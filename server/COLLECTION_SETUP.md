# 📋 Configuration de la collection `recalls` dans PocketBase

## 🎯 Objectif

Créer la collection `recalls` qui stockera tous les rappels produits.

---

## ⚙️ Étapes de création

### 1️⃣ Ouvre l'interface PocketBase Admin

```bash
# Dans le dossier server/
./pocketbase.exe serve
```

- Ouvre http://localhost:8090/_/ dans le navigateur
- Login avec l'admin root (credentials par défaut si première utilisation)

### 2️⃣ Crée une nouvelle collection

1. Clique sur **➕ New collection** (ou **Create collection**)
2. Dans le formulaire, remplis :
   - **ID** : `recalls`
   - **Name** : `Rappels Produits`
   - **Type** : `Database`
3. Clique **Create**

### 3️⃣ Ajoute les champs (Fields)

Une fois la collection créée, ajoute ces champs dans l'ordre :

#### Field 1 : **barcode** (clé primaire)
- **Field name** : `barcode`
- **Field type** : `Text`
- **Required** : ✅ Oui
- **Unique** : ✅ Oui (important pour éviter les doublons !)
- **Searchable** : ✅ Oui
- **Indexed** : ✅ Oui
- **Description** : Code-barres ou GTIN du produit

**➕ Save field**

#### Field 2 : **product_name**
- **Field name** : `product_name`
- **Field type** : `Text`
- **Required** : ❌ Non
- **Searchable** : ✅ Oui
- **Description** : Nom du produit rappelé

**➕ Save field**

#### Field 3 : **brand**
- **Field name** : `brand`
- **Field type** : `Text`
- **Required** : ❌ Non
- **Description** : Marque du produit

**➕ Save field**

#### Field 4 : **reason**
- **Field name** : `reason`
- **Field type** : `Rich Editor` (ou `Text` si tu veux simple)
- **Required** : ❌ Non
- **Description** : Raison du rappel (allergen risk, contamination, etc.)

**➕ Save field**

#### Field 5 : **risk**
- **Field name** : `risk`
- **Field type** : `Select`
- **Values** : `low`, `medium`, `high` (une par ligne)
- **Required** : ❌ Non
- **Default value** : `low`
- **Description** : Niveau de risque

**➕ Save field**

#### Field 6 : **publication_date**
- **Field name** : `publication_date`
- **Field type** : `Date`
- **Required** : ❌ Non
- **Description** : Date de publication du rappel

**➕ Save field**

#### Field 7 : **end_date**
- **Field name** : `end_date`
- **Field type** : `Date`
- **Required** : ❌ Non
- **Description** : Date de fin du rappel

**➕ Save field**

#### Field 8 : **distributors**
- **Field name** : `distributors`
- **Field type** : `Text`
- **Required** : ❌ Non
- **Description** : Distributeurs affectés (ALDI, CARREFOUR, etc.)

**➕ Save field**

#### Field 9 : **geographic_area**
- **Field name** : `geographic_area`
- **Field type** : `Text`
- **Required** : ❌ Non
- **Default value** : `France`
- **Description** : Zone géographique du rappel

**➕ Save field**

#### Field 10 : **source_url**
- **Field name** : `source_url`
- **Field type** : `URL`
- **Required** : ❌ Non
- **Description** : Lien vers la source du rappel

**➕ Save field**

---

## 🔐 Configurer les règles d'accès (API Rules)

Une fois les champs créés, configure les **règles d'accès**.

### Dans PocketBase Admin

1. Va dans l'onglet **API Rules** de la collection `recalls`
2. Configure les rules suivantes :

#### **List Rule** (pour lire la liste)
```
true
```
→ Tout le monde peut voir la liste des rappels

#### **View Rule** (pour lire un rappel)
```
true
```
→ Tout le monde peut voir les détails d'un rappel

#### **Create Rule**
```
false
```
→ Personne ne peut créer (seul le cron/serveur le fait)

#### **Update Rule**
```
false
```
→ Personne ne peut modifier (seul le cron le fait)

#### **Delete Rule**
```
false
```
→ Personne ne peut supprimer

### Clique **Save**

---

## ✅ Vérification

### Vérifie que c'est bon :

1. Dans PocketBase Admin, clique sur **Collections** dans le menu
2. Tu dois voir `recalls` avec 10 champs
3. Clique sur **recalls** et vérifie les champs
4. Clique sur l'onglet **API Rules** et confirme les configurations

### Teste le hook :

1. Redémarre PocketBase (Ctrl+C et `./pocketbase.exe serve`)
2. Dans la console, tu devrais voir :
   ```
   [2026-03-24T...] ✓ PocketBase booting - registering recalls cron job
   [2026-03-24T...] ✓ Collection 'recalls' exists
   [2026-03-24T...] ✓ Cron job registered: "0 6,18 * * *" ...
   ```
3. ✅ C'est bon !

### Test d'import manuel (si tu veux tester avant l'heure du cron) :

Pour l'instant, le cron tests se feront automatiquement à 06:00 et 18:00.  
Pour tester manuellement, tu peux :

1. Modifier temporairement `pb_hooks/main.js` :
   ```javascript
   // Remplace CRON_EXPRESSION par :
   const CRON_EXPRESSION = '*/5 * * * *'; // Chaque 5 minutes (test)
   ```
2. Redémarre PocketBase
3. Attends 5 minutes et regarde les logs
4. Une fois testé, remets `'0 6,18 * * *'` et redémarre

---

## 📦 Export de la collection (optionnel)

Si tu veux exporter la configuration de la collection pour la partager :

1. PocketBase Admin → Collections
2. Clique sur `recalls`
3. Clique l'icône **Export** (coin supérieur)
4. Télécharge le fichier JSON
5. Mets-le dans `server/` (ex: `recalls_collection.json`)
6. Commit sur git pour que le binôme le voit

---

## 🚀 Prochaine étape

Une fois la collection créée et les hooks enregistrés,  
tu peux partir sur le développement Flutter pour **interroger la collection**.

Voir `README.md` pour les exemples d'appels Flutter.
