import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

abstract class IAuthService extends ChangeNotifier {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password);
  Future<void> logout();
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool get isLoading;
}

class AuthService extends IAuthService {
  final FirebaseAuth _auth;
  User? _user;
  bool _isLoading = false;
  StreamSubscription<User?>? _authStateSubscription;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _authStateSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _onAuthStateChanged(User? newUser) {
    if (_user != newUser) {
      _user = newUser;
      if (_isLoading) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  @override
  User? get currentUser => _user;
  @override
  bool get isLoading => _isLoading;
  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'weak-password') {
        throw AuthException('A senha informada é muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('O e-mail informado já está em uso.');
      }
    }
  }

  @override
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      if (e.code == 'user-not-found') {
        throw AuthException('O e-mail informado não foi encontrado.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta.');
      } else {
        throw AuthException('Ocorreu um erro. Verifique suas credenciais.');
      }
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}