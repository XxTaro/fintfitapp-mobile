// test/services/auth_service_test.dart

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  User,
  UserCredential,
])
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  late StreamController<User?> authStateController;

  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUserCredential = MockUserCredential();
    authStateController = StreamController<User?>();

    when(mockUserCredential.user).thenReturn(mockUser);

    when(mockAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);

    authService = AuthService(auth: mockAuth);
  });

  tearDown(() {
    authStateController.close();
  });

  // Criando um grupo de testes com tearDown para garantir que o authService.dispose() seja chamado após cada teste
  // e consequentemente para não quebrar o último teste de dispose.
  group('grupo com tearDown com authService.dispose()', () {
    tearDown(() {
      authService.dispose();
    });

    test('Estado inicial deve ser deslogado e sem loading', () {
      expect(authService.currentUser, isNull);
      expect(authService.isLoading, isFalse);
    });

    group('Login', () {
      test('deve logar com sucesso, atualizar o usuário e o estado de loading',
          () async {
        // Arrange
        when(mockAuth.signInWithEmailAndPassword(
                email: 'test@test.com', password: 'password'))
            .thenAnswer((_) async => mockUserCredential);

        int listenerCallCount = 0;
        authService.addListener(() => listenerCallCount++);

        // Act
        final loginFuture = authService.login('test@test.com', 'password');

        // Assert (durante a execução)
        expect(authService.isLoading, isTrue);
        expect(listenerCallCount, 1);

        // Simula o Firebase notificando que o usuário mudou
        authStateController.add(mockUser);

        await Future.delayed(Duration.zero);

        // Espera o processo de login terminar
        await loginFuture;

        // Assert (após a execução)
        expect(authService.currentUser, mockUser);
        expect(authService.isLoading, isFalse);
        expect(listenerCallCount, 2);
        verify(mockAuth.signInWithEmailAndPassword(
                email: 'test@test.com', password: 'password'))
            .called(1);
      });

      test('deve lançar AuthException para senha incorreta', () async {
        // Arrange
        final exception = FirebaseAuthException(code: 'wrong-password');
        when(mockAuth.signInWithEmailAndPassword(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.login('test@test.com', 'wrongpass'),
          throwsA(isA<AuthException>()
            ..having((e) => e.message, 'message', 'Senha incorreta.')),
        );
        // Garante que o loading foi desligado mesmo com erro
        expect(authService.isLoading, isFalse);
      });
    });

    group('Register', () {
      test('deve registrar um novo usuário com sucesso', () async {
        // Arrange
        when(mockAuth.createUserWithEmailAndPassword(
                email: 'new@test.com', password: 'password'))
            .thenAnswer((_) async => mockUserCredential);

        // Act
        final registerFuture = authService.register('new@test.com', 'password');
        // Simula o Firebase notificando o novo usuário
        authStateController.add(mockUser);
        await Future.delayed(Duration.zero);
        await registerFuture;

        // Assert
        expect(authService.currentUser, mockUser);
        expect(authService.isLoading, isFalse);
        verify(mockAuth.createUserWithEmailAndPassword(
                email: 'new@test.com', password: 'password'))
            .called(1);
      });

      test('deve lançar AuthException para email já em uso', () {
        // Arrange
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        when(mockAuth.createUserWithEmailAndPassword(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenThrow(exception);

        // Act & Assert
        expect(
          () => authService.register('used@test.com', 'password'),
          throwsA(isA<AuthException>()
            ..having((e) => e.message, 'message',
                'O e-mail informado já está em uso.')),
        );
        expect(authService.isLoading, isFalse);
      });
    });

    group('Logout', () {
      test('deve deslogar o usuário e limpar o estado', () async {
        // Arrange
        authStateController.add(mockUser);
        await Future.delayed(Duration.zero);
        expect(authService.currentUser, mockUser);

        when(mockAuth.signOut()).thenAnswer((_) async {});

        // Act
        final logoutFuture = authService.logout();
        // Simula o Firebase notificando que não há mais usuário
        authStateController.add(null);
        await Future.delayed(Duration.zero);
        await logoutFuture;

        // Assert
        expect(authService.currentUser, isNull);
        verify(mockAuth.signOut()).called(1);
      });
    });
  });

  group('Dispose', () {
    test('deve cancelar a inscrição do authStateChanges', () async {
      var isCancelled = false;
      // O onCancel é um callback do StreamController que é chamado
      // quando a inscrição (subscription) feita nele é cancelada.
      authStateController.onCancel = () {
        isCancelled = true;
      };

      // Act
      authService.dispose();

      // Assert
      // Verificamos se o nosso callback foi de fato chamado.
      expect(isCancelled, isTrue);
    });
  });
}
