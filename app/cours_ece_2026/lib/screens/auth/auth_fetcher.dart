import 'package:flutter/material.dart';
import 'package:formation_flutter/screens/product/recall_fetcher.dart';

class AuthFetcher extends ChangeNotifier {
  AuthFetcher() : _state = AuthInitial();

  AuthState _state;
  AuthState get state => _state;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      await pb.collection('users').authWithPassword(email, password);
      print(pb.authStore.model);
      print(pb.authStore.isValid);
      _state = AuthSuccess();
    } catch (e) {
      _state = AuthError(e.toString());
    }

    notifyListeners();
  }

  Future<void> signup({
    required String email,
    required String password,
  }) async {
    _state = AuthLoading();
    notifyListeners();

    try {
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password,
      });

      await pb.collection('users').authWithPassword(email, password);

      print(pb.authStore.model);
      print(pb.authStore.isValid);
      _state = AuthSuccess();
    } catch (e) {
      _state = AuthError(e.toString());
    }

    notifyListeners();
  }

  void logout() {
    pb.authStore.clear();
    _state = AuthInitial();
    notifyListeners();
  }

  bool get isLoggedIn => pb.authStore.isValid;
}

sealed class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthError extends AuthState {
  AuthError(this.message);
  final String message;
}