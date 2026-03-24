# 🧪 Guide de test - Authentification PocketBase

## 🎯 Objectif

Tester complètement l'authentification avec PocketBase :
- Inscription
- Connexion
- Persistance de session
- Déconnexion
- Protection des routes

---

## 🚀 Démarrage

### 1️⃣ Lance PocketBase

```bash
cd server
./pocketbase.exe serve
```

### 2️⃣ Lance l'app Flutter

```bash
cd app/cours_ece_2026
flutter run
```

---

## 🧪 Tests à effectuer

### Test 1 : Inscription

1. **Lance l'app** → Tu arrives sur la page de connexion
2. **Clique "Pas de compte ? Créer un compte"**
3. **Remplis** :
   - Email : `test@example.com`
   - Mot de passe : `test123456`
4. **Clique "S'inscrire"**
5. **Résultat attendu** :
   - ✅ Redirection automatique vers `/home`
   - ✅ Message dans les logs Flutter : "✅ Account created successfully"

### Test 2 : Connexion

1. **Ferme l'app** (Ctrl+C)
2. **Relance l'app** (`flutter run`)
3. **Tu arrives sur la page de connexion** (session perdue)
4. **Remplis** :
   - Email : `test@example.com`
   - Mot de passe : `test123456`
5. **Clique "Se connecter"**
6. **Résultat attendu** :
   - ✅ Redirection vers `/home`
   - ✅ Session persistante (si tu fermes/relances l'app, tu restes connecté)

### Test 3 : Protection des routes

1. **Modifie temporairement l'URL** dans le navigateur Flutter :
   - Change `http://localhost:8080/#/home` → `http://localhost:8080/#/favorites`
2. **Résultat attendu** :
   - ✅ Redirection automatique vers `/` (page de login)

### Test 4 : Déconnexion

1. **Ajoute un bouton de déconnexion** dans `HomePage` (voir section ci-dessous)
2. **Clique dessus**
3. **Résultat attendu** :
   - ✅ Redirection vers `/`
   - ✅ Session terminée

---

## 🔧 Ajouter un bouton de déconnexion

### Dans `lib/screens/homepage/homepage_screen.dart`

Ajoute dans le `Scaffold` :

```dart
appBar: AppBar(
  title: const Text('Accueil'),
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        // Utilise l'AuthFetcher pour se déconnecter
        context.read<AuthFetcher>().logout();
      },
    ),
  ],
),
```

**Note** : Assure-toi que `HomePage` a accès à `AuthFetcher` via Provider.

---

## 📊 Logs attendus

### Au lancement de l'app

```
=== Setting up PocketBase Collections ===
Found 2 collections
✅ Users collection exists
✅ Recalls collection exists
=== Setup Complete ===
```

### Lors de l'inscription

```
✅ Account created successfully
✅ Auto-login after signup successful
User ID: xxx
```

### Lors de la connexion

```
✅ Login successful
User ID: xxx
Email: test@example.com
```

### Lors de la déconnexion

```
✅ User logged out
```

---

## 🔍 Dépannage

### Problème : "Users collection missing"

**Solution** :
1. Va dans PocketBase Admin : http://127.0.0.1:8090/_/
2. Crée un compte admin si demandé
3. La collection `users` devrait être créée automatiquement

### Problème : "Invalid login credentials"

**Cause** : User n'existe pas ou mauvais mot de passe

**Solution** :
- Vérifie l'email/mot de passe
- Dans PocketBase Admin, vérifie que l'user existe dans la collection `users`

### Problème : Pas de redirection après connexion

**Cause** : Router pas configuré correctement

**Solution** :
- Vérifie que `AuthSuccess` déclenche `context.go('/home')`
- Vérifie les logs Flutter pour voir si l'auth réussit

### Problème : Session pas persistante

**Cause** : PocketBase ne sauvegarde pas la session

**Solution** :
- Vérifie que `pb.authStore.isValid` retourne `true` après connexion
- La persistance est automatique avec PocketBase

---

## 🧪 Tests avancés

### Test avec plusieurs utilisateurs

1. Crée un deuxième compte : `test2@example.com`
2. Connecte-toi avec le premier, vérifie que tu vois ses données
3. Déconnecte-toi, connecte-toi avec le deuxième

### Test des erreurs

1. Essaie de t'inscrire avec un email déjà utilisé
2. Essaie de te connecter avec un mauvais mot de passe
3. Vérifie que les messages d'erreur s'affichent correctement

---

## 📱 États d'authentification

L'app gère 4 états :

1. **`AuthInitial`** : État initial, pas connecté
2. **`AuthLoading`** : Chargement pendant connexion/inscription
3. **`AuthSuccess`** : Connexion réussie → redirection vers `/home`
4. **`AuthError`** : Erreur → affichage du message

---

## 🔐 Sécurité

- **Mots de passe** : Hashés automatiquement par PocketBase
- **Sessions** : Gérées par tokens JWT
- **Routes protégées** : Redirection automatique si pas connecté
- **API Rules** : Seuls les users connectés peuvent accéder aux données sensibles

---

## 🚀 Production

### Variables d'environnement

Pour la production, utilise des variables d'environnement :

```dart
final pb = PocketBase(
  const String.fromEnvironment('POCKETBASE_URL', defaultValue: 'http://127.0.0.1:8090')
);
```

### Build de prod

```bash
flutter build apk --dart-define=POCKETBASE_URL=https://ton-domaine.com
```

---

## ✅ Checklist de validation

- [ ] Inscription fonctionne
- [ ] Connexion fonctionne
- [ ] Session persistante entre lancements
- [ ] Protection des routes
- [ ] Déconnexion fonctionne
- [ ] Messages d'erreur appropriés
- [ ] Logs informatifs

---

**Tous les tests passent ?** 🎉 L'authentification est prête !

**Besoin d'aide ?** Consulte les logs Flutter et PocketBase pour diagnostiquer.
