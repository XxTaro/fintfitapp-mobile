import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

// 1. Mock para a classe User (pode ser simples)
class MockUser implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
  @override
  final bool isAnonymous;

  MockUser({
    this.uid = '12345',
    this.email = 'mock@test.com',
    this.displayName = 'Mock User',
    this.isAnonymous = false,
  });

  // Você precisará implementar os outros getters e métodos com valores padrão
  // ou lançando UnimplementedError se não for usá-los.
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUserCredential implements UserCredential {
  // A única propriedade que geralmente nos importa nos testes é o 'user'
  @override
  final User? user;

  MockUserCredential({this.user});

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// 2. O MockFirebaseAuth "Inteligente"
class MockFirebaseAuth implements FirebaseAuth {
  // O controlador do nosso stream de autenticação
  final StreamController<User?> _streamController;

  // Variável para simular o estado atual
  User? mockUser;

  MockFirebaseAuth({this.mockUser}) 
    // Inicializa o controlador com `sync: true` para que os eventos
    // sejam processados imediatamente nos testes.
    : _streamController = StreamController<User?>.broadcast(sync: true) {
      // Emite o estado inicial quando o mock é criado
      _streamController.add(mockUser);
    }

  // O getter mais importante: ele retorna o stream do nosso controlador.
  // A AuthService vai ouvir este stream.
  @override
  Stream<User?> authStateChanges() => _streamController.stream;

  // Agora, os métodos de ação PRECISAM emitir eventos no stream.
  @override
  Future<void> signOut() async {
    mockUser = null;
    // Quando signOut é chamado, emitimos `null` no stream.
    log('MockFirebaseAuth: signOut called');
    _streamController.add(null);
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Simula um login bem-sucedido
    mockUser = MockUser(email: email);
    // Emite o novo usuário no stream
    _streamController.add(mockUser);
    // Retorna um MockUserCredential
    // (você precisaria criar uma classe MockUserCredential também)
    // Para este teste, o mais importante é a linha de cima.
    return MockUserCredential(user: mockUser);
  }

  // O `currentUser` deve retornar o estado atual
  @override
  User? get currentUser => mockUser;
  
  // Implemente outros métodos com `UnimplementedError` ou comportamento mockado
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}