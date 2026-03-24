import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../test_pocketbase.dart';

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
    _checkExistingSession();
  }

  AuthState _state = AuthInitial();
  AuthState get state => _state;

  void _checkExistingSession() {
    if (pb.authStore.isValid) {
      _state = AuthSuccess();
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _state = AuthLoading();
    notifyListeners();

    final localError = _validateCredentials(
      email: email,
      password: password,
      isSignup: false,
    );
    if (localError != null) {
      _state = AuthError(localError);
      notifyListeners();
      return;
    }

    try {
      await pb.collection('users').authWithPassword(email, password);
      _state = AuthSuccess();
    } catch (e) {
      _state = AuthError(_parseAuthError(e, isSignup: false));
    }

    notifyListeners();
  }

  Future<void> signup({required String email, required String password}) async {
    _state = AuthLoading();
    notifyListeners();

    final localError = _validateCredentials(
      email: email,
      password: password,
      isSignup: true,
    );
    if (localError != null) {
      _state = AuthError(localError);
      notifyListeners();
      return;
    }

    try {
      await pb.collection('users').create(
        body: {
          'email': email,
          'password': password,
          'passwordConfirm': password,
        },
      );

      await pb.collection('users').authWithPassword(email, password);
      _state = AuthSuccess();
    } catch (e) {
      _state = AuthError(_parseAuthError(e, isSignup: true));
    }

    notifyListeners();
  }

  void logout() {
    pb.authStore.clear();
    _state = AuthInitial();
    notifyListeners();
  }

  bool get isLoggedIn => pb.authStore.isValid;

  String? _validateCredentials({
    required String email,
    required String password,
    required bool isSignup,
  }) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (email.isEmpty || password.isEmpty) {
      return 'Veuillez remplir tous les champs';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'Adresse email invalide';
    }
    if (isSignup && password.length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caracteres';
    }

    return null;
  }

  String _parseAuthError(Object error, {required bool isSignup}) {
    if (error is ClientException) {
      final response = error.response;
      final message = (response['message'] ?? '').toString();
      final data = response['data'];

      if (message.contains('Invalid login credentials')) {
        return 'Email ou mot de passe incorrect';
      }

      if (data is Map<String, dynamic>) {
        final emailError = data['email'];
        final passwordError = data['password'];

        if (emailError is Map<String, dynamic>) {
          final emailMessage = (emailError['message'] ?? '').toString();
          if (emailMessage.contains('already') ||
              emailMessage.contains('exists')) {
            return 'Cet email est deja utilise';
          }
          if (emailMessage.isNotEmpty) {
            return 'Adresse email invalide';
          }
        }

        if (passwordError is Map<String, dynamic>) {
          final passwordMessage = (passwordError['message'] ?? '').toString();
          if (passwordMessage.isNotEmpty) {
            return 'Le mot de passe doit contenir au moins 8 caracteres';
          }
        }
      }
    }

    final errorText = error.toString();

    if (errorText.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    }
    if (errorText.contains('already exists')) {
      return 'Cet email est deja utilise';
    }
    if (errorText.contains('password')) {
      return 'Le mot de passe est invalide';
    }
    if (errorText.contains('email')) {
      return 'Adresse email invalide';
    }
    if (errorText.contains('validation')) {
      return isSignup
          ? 'Informations invalides pour creer le compte'
          : 'Informations de connexion invalides';
    }
    if (errorText.contains('network') || errorText.contains('connection')) {
      return 'Erreur de connexion. Verifiez votre connexion internet';
    }

    return isSignup
        ? 'Erreur lors de la creation du compte. Reessayez plus tard'
        : 'Erreur d\'authentification. Reessayez plus tard';
  }
}
