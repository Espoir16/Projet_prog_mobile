# 👥 Configuration de l'authentification PocketBase

## 🎯 Objectif

Configurer l'authentification utilisateur avec PocketBase pour permettre :
- Inscription (signup)
- Connexion (login)
- Gestion des sessions

---

## 📋 Collection `users` (automatique)

PocketBase crée automatiquement une collection `users` lors du premier démarrage.

### Champs par défaut :
- `id` (auto)
- `email` (unique, required)
- `password` (hashed, required)
- `emailVisibility` (bool)
- `verified` (bool)
- `created` (autodate)
- `updated` (autodate)

---

## 🔐 Règles d'accès (API Rules)

### Dans PocketBase Admin

1. Va dans **Collections** → **users**
2. Onglet **API Rules**
3. Configure :

#### **List Rule**
```
auth.isValid
```
→ Seuls les utilisateurs connectés peuvent lister les users

#### **View Rule**
```
auth.isValid
```
→ Seuls les utilisateurs connectés peuvent voir les détails

#### **Create Rule**
```
true
```
→ Tout le monde peut créer un compte (signup)

#### **Update Rule**
```
auth.isValid && auth.id = @request.auth.id
```
→ Un user ne peut modifier que son propre profil

#### **Delete Rule**
```
auth.isValid && auth.id = @request.auth.id
```
→ Un user ne peut supprimer que son propre compte

### Clique **Save**

---

## 🧪 Test de l'authentification

### 1️⃣ Lance l'app Flutter

```bash
flutter run
```

Tu devrais voir dans les logs :
```
=== Setting up PocketBase Collections ===
Found X collections
✅ Users collection exists
✅ Recalls collection exists
=== Setup Complete ===

=== Testing Auth Flow ===
Testing signup...
✅ Signup successful
Testing login...
✅ Login successful
User ID: xxx
Is valid: true
✅ Logout successful
```

### 2️⃣ Test manuel dans l'app

- **Inscription** : Crée un compte avec email/mot de passe
- **Connexion** : Connecte-toi avec les mêmes credentials
- **Navigation** : Après connexion, tu devrais aller sur `/home`

---

## 🔧 Code Flutter (déjà configuré)

### AuthFetcher (`lib/screens/auth/auth_fetcher.dart`)

```dart
class AuthFetcher extends ChangeNotifier {
  Future<void> login({required String email, required String password}) async {
    // Utilise pb.collection('users').authWithPassword()
  }

  Future<void> signup({required String email, required String password}) async {
    // Crée le user puis le connecte automatiquement
  }

  void logout() {
    pb.authStore.clear(); // Déconnecte
  }

  bool get isLoggedIn => pb.authStore.isValid; // Vérifie si connecté
}
```

### PocketBase instance (`lib/test_pocketbase.dart`)

```dart
final pb = PocketBase('http://127.0.0.1:8090');
```

---

## 📱 États d'authentification

### Dans AuthFetcher

```dart
sealed class AuthState {}

class AuthInitial extends AuthState {}      // État initial
class AuthLoading extends AuthState {}      // Chargement
class AuthSuccess extends AuthState {}      // Succès → navigation vers /home
class AuthError extends AuthState {         // Erreur → affichage message
  AuthError(this.message);
  final String message;
}
```

### Gestion dans LoginPage

```dart
Consumer<AuthFetcher>(
  builder: (context, auth, _) {
    final state = auth.state;

    if (state is AuthSuccess) {
      // Navigation automatique vers home
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Column(
      children: [
        // Champs email/password
        // Boutons Connexion/Inscription
        if (state is AuthLoading) CircularProgressIndicator(),
        if (state is AuthError) Text(state.message, style: TextStyle(color: Colors.red)),
      ],
    );
  },
)
```

---

## 🔍 Dépannage

### Erreur "Users collection missing"

**Cause** : PocketBase n'a pas créé la collection automatiquement

**Solution** :
1. PocketBase Admin → **Settings** → **Create admin account** (si pas fait)
2. La collection `users` devrait être créée automatiquement

### Erreur "authWithPassword failed"

**Cause** : Email/password incorrects ou user non vérifié

**Solution** :
- Vérifie les credentials
- Dans PocketBase Admin, vérifie que l'user existe et est `verified: true`

### Erreur réseau

**Cause** : PocketBase pas lancé ou URL incorrecte

**Solution** :
```bash
cd server
./pocketbase.exe serve
```
Vérifie l'URL dans `test_pocketbase.dart` : `http://127.0.0.1:8090`

---

## 🚀 Production

### URL PocketBase

En prod, change l'URL :
```dart
final pb = PocketBase('https://ton-domaine.com');
```

### Sécurisation

- Active HTTPS
- Configure CORS dans PocketBase
- Utilise des variables d'environnement pour l'URL

---

## 📚 Ressources

- [PocketBase Auth Documentation](https://pocketbase.io/docs/authentication/)
- [Flutter PocketBase Package](https://pub.dev/packages/pocketbase)

---

**Prêt à tester l'authentification !** 🚀
