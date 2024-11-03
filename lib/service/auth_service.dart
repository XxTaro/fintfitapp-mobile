import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user;
  bool isLoading = true;

  AuthService() {
    _authCheck();
  }

  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      user = user;
      isLoading = false;
      notifyListeners();
    });
  }

  registerUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('A senha informada é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('O e-mail informado já está em uso.');
      }
    }
  }

  login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _getUser();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('O e-mail informado não foi encontrado.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta.');
      }
    }
  }

  logout() {
    _auth.signOut();
    _getUser();
  }

  _getUser() {
    user = _auth.currentUser;
    notifyListeners();
  }

}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);
}