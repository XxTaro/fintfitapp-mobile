import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

// É interessante demonstrar no trabalho comentando todo esse teste e evidenciar que teste de código não pode ser somente
// baseado pela cobertura, mas sim pela lógica de negócio que está sendo testada. Pois mesmo com esse teste, já existe 
// cobertura na classe AuthService devido aos outros testes
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
        // Given
        when(mockAuth.signInWithEmailAndPassword(
                email: 'test@test.com', password: 'password'))
            .thenAnswer((_) async => mockUserCredential);

        int listenerCallCount = 0;
        authService.addListener(() => listenerCallCount++);

        // When
        final loginFuture = authService.login('test@test.com', 'password');

        // Then
        expect(authService.isLoading, isTrue);
        expect(listenerCallCount, 1);

        // Simula o Firebase notificando que o usuário mudou
        authStateController.add(mockUser);

        await Future.delayed(Duration.zero);

        // Espera o processo de login terminar
        await loginFuture;

        // Then (após a execução)
        expect(authService.currentUser, mockUser);
        expect(authService.isLoading, isFalse);
        expect(listenerCallCount, 2);
        verify(mockAuth.signInWithEmailAndPassword(
                email: 'test@test.com', password: 'password'))
            .called(1);
      });

      test('deve lançar AuthException para senha incorreta', () async {
        // Given
        final exception = FirebaseAuthException(code: 'wrong-password');
        when(mockAuth.signInWithEmailAndPassword(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenThrow(exception);

        // When & Then
        expect(
          () => authService.login('test@test.com', 'wrongpass'),
          throwsA(isA<AuthException>()
            ..having((e) => e.message, 'message', 'Senha incorreta.')),
        );
        expect(authService.isLoading, isFalse);
      });

      test('deve lançar AuthException para usuário não encontrado', () async {
        // Given
        final exception = FirebaseAuthException(code: 'user-not-found');
        when(mockAuth.signInWithEmailAndPassword(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenThrow(exception);

        // When & Then
        expect(
          () => authService.login('test@test.com', 'wrongpass'),
          throwsA(isA<AuthException>()
            ..having((e) => e.message, 'message', 'Usuário não encontrado.')),
        );
        expect(authService.isLoading, isFalse);
      });
    });

    group('Register', () {
      test('deve registrar um novo usuário com sucesso', () async {
        // Given
        when(mockAuth.createUserWithEmailAndPassword(
                email: 'new@test.com', password: 'password'))
            .thenAnswer((_) async => mockUserCredential);

        // When
        final registerFuture = authService.register('new@test.com', 'password');
        authStateController.add(mockUser);
        await Future.delayed(Duration.zero);
        await registerFuture;

        // Then
        expect(authService.currentUser, mockUser);
        expect(authService.isLoading, isFalse);
        verify(mockAuth.createUserWithEmailAndPassword(
                email: 'new@test.com', password: 'password'))
            .called(1);
      });

      test('deve lançar AuthException para email já em uso', () {
        // Given
        final exception = FirebaseAuthException(code: 'email-already-in-use');
        when(mockAuth.createUserWithEmailAndPassword(
                email: anyNamed('email'), password: anyNamed('password')))
            .thenThrow(exception);

        // When & Then
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
        // Given
        authStateController.add(mockUser);
        await Future.delayed(Duration.zero);
        expect(authService.currentUser, mockUser);

        when(mockAuth.signOut()).thenAnswer((_) async {});

        // When
        final logoutFuture = authService.logout();
        authStateController.add(null);
        await Future.delayed(Duration.zero);
        await logoutFuture;

        // Then
        expect(authService.currentUser, isNull);
        verify(mockAuth.signOut()).called(1);
      });
    });
  });

  group('Dispose', () {
    test('deve cancelar a inscrição do authStateChanges', () async {
      // Given
      var isCancelled = false;
      authStateController.onCancel = () {
        isCancelled = true;
      };

      // When
      authService.dispose();

      // Then
      expect(isCancelled, isTrue);
    });
  });
}
