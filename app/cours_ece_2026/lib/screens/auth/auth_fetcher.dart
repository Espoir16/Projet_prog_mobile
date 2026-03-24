import 'package:flutter/material.dart';
import '../../test_pocketbase.dart'; // Import pb instance

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}

class AuthFetcher extends ChangeNotifier {
  AuthFetcher() : _state = AuthInitial() {
    // Vérifier si l'utilisateur est déjà connecté au démarrage
    _checkExistingSession();
  }

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  // Vérifier la session existante au démarrage
  void _checkExistingSession() {
    if (pb.authStore.isValid) {
      _state = AuthSuccess();
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      await pb.collection('users').authWithPassword(email, password);
      // pas de save() car la version actuelle de pocketbase.dart demande 2 args
      print('✅ Login successful');
      print('User ID: ${pb.authStore.model?.id}');
      print('Email: ${pb.authStore.model?.getStringValue('email')}');
      _state = AuthSuccess();
    } catch (e) {
      print('❌ Login failed: $e');
      _state = AuthError(_parseAuthError(e.toString()));
    }

    notifyListeners();
  }

  Future<void> signup({required String email, required String password}) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      // Créer le compte
      await pb
          .collection('users')
          .create(
            body: {
              'email': email,
              'password': password,
              'passwordConfirm': password,
            },
          );
      print('✅ Account created successfully');

      // Se connecter automatiquement
      await pb.collection('users').authWithPassword(email, password);
      // pas de save() ici non plus, pour compatibilité avec la version actuelle.
      print('✅ Auto-login after signup successful');
      print('User ID: ${pb.authStore.model?.id}');

      _state = AuthSuccess();
    } catch (e) {
      print('❌ Signup failed: $e');
      _state = AuthError(_parseAuthError(e.toString()));
    }

    notifyListeners();
  }

  void logout() {
    pb.authStore.clear();
    print('✅ User logged out');
    _state = AuthInitial();
    notifyListeners();
  }

  bool get isLoggedIn => pb.authStore.isValid;

  // Parser les erreurs PocketBase pour des messages user-friendly
  String _parseAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (error.contains('already exists')) {
      return 'Cet email est déjà utilisé';
    }
    if (error.contains('validation')) {
      return 'Données invalides. Vérifiez votre email et mot de passe';
    }
    if (error.contains('network') || error.contains('connection')) {
      return 'Erreur de connexion. Vérifiez votre connexion internet';
    }
    return 'Erreur d\'authentification. Réessayez plus tard';
  }
}
