import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/ui/auth_check.dart';
import 'package:fin_fit_app_mobile/ui/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mock_exceptions/mock_exceptions.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());

    // When
    await tester.pumpWidget(loginPage);

    //Then
    expect(find.text('Bem-vindo!'), findsOne,
        reason:
            'Checking if the welcome title is displayed correctly when page is loaded');
    expect(find.text('Login'), findsOne,
        reason:
            'Checking if the login button text is displayed correctly when page is loaded');
    expect(find.text('Ainda não tem uma conta? Cadastre-se agora!'), findsOne,
        reason:
            'Checking if the toggle button text is displayed correctly when page is loaded');

    expect(find.byKey(const ValueKey('formFieldEmail')), findsOne,
        reason:
            'Checking if the email form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('formFieldPassword')), findsOne,
        reason:
            'Checking if the password form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterAction')), findsOne,
        reason:
            'Checking if the login or register button is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterToggle')), findsOne,
        reason:
            'Checking if the toggle button is displayed correctly when page is loaded');
  });

  testWidgets(
      'Login page switches login format to register when toggle is clicked',
      (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());
    await tester.pumpWidget(loginPage);

    // When
    Finder toggleButton =
        find.byKey(const ValueKey('buttonLoginRegisterToggle'));
    await tester.tap(toggleButton);
    await tester.pumpAndSettle();

    //Then
    expect(find.text('Crie sua conta'), findsOne,
        reason:
            'Checking if the welcome title is displayed correctly when page is loaded');
    expect(find.text('Cadastrar'), findsOne,
        reason:
            'Checking if the register button text is displayed correctly when page is loaded');
    expect(find.text('Já tenho uma conta'), findsOne,
        reason:
            'Checking if the toggle button text is displayed correctly when page is loaded');

    expect(find.byKey(const ValueKey('formFieldEmail')), findsOne,
        reason:
            'Checking if the email form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('formFieldPassword')), findsOne,
        reason:
            'Checking if the password form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterAction')), findsOne,
        reason:
            'Checking if the login or register button is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterToggle')), findsOne,
        reason:
            'Checking if the toggle button is displayed correctly when page is loaded');
  });

  testWidgets('Error shows when e-mail field is empty',
      (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());
    await tester.pumpWidget(loginPage);
    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    TextFormField passwordField = tester.widget(passwordFinder);
    passwordField.controller!.text = "Not empty";

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 100));

    //Then
    final emailErrorFinder = find.text('Por favor, insira um e-mail');
    expect(emailErrorFinder, findsOneWidget,
        reason:
            'Checking if the error message is displayed when e-mail field is empty');
  });

  testWidgets('Error shows when password field is empty',
      (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());
    await tester.pumpWidget(loginPage);
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    TextFormField emailField = tester.widget(emailFinder);
    emailField.controller!.text = "Not empty";

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 100));

    //Then
    final passwordErrorFinder = find.text('Por favor, insira a senha');
    expect(passwordErrorFinder, findsOneWidget,
        reason:
            'Checking if the error message is displayed when password field is empty');
  });

  testWidgets('Error shows when password field lenght is less than 6',
      (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());
    await tester.pumpWidget(loginPage);
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    TextFormField emailField = tester.widget(emailFinder);
    emailField.controller!.text = "Not empty";

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    TextFormField passwordField = tester.widget(passwordFinder);
    passwordField.controller!.text = "12345";

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 100));

    //Then
    final passwordErrorFinder =
        find.text('A senha deve ter no mínimo 6 caracteres');
    expect(passwordErrorFinder, findsOneWidget,
        reason:
            'Checking if the error message is displayed when password lenght is less than 6 characters');
  });

  testWidgets('Successfully logged in', (WidgetTester tester) async {
    //Given
    // Cria um usuário fake que indica que o login será bem-sucedido
    final mockUser = MockUser(
      isAnonymous: false,
      uid: '123',
      email: 'teste@teste.com',
      displayName: 'Usuario Teste',
    );

    // Cria a instância mockada do FirebaseAuth utilizando firebase_auth_mocks
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final sucessSnackbar = find.text('Login efetuado com sucesso!');
    expect(sucessSnackbar, findsOneWidget,
        reason:
            'Checking if the success message is displayed when login is successful');
    final initialPage = find.byKey(const ValueKey('statefulMainPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the user is redirected to the initial page when login is successful');
  });

  testWidgets('Successfully logged in', (WidgetTester tester) async {
    //Given
    // Cria um usuário fake que indica que o login será bem-sucedido
    final mockUser = MockUser(
      isAnonymous: false,
      uid: '123',
      email: 'teste@teste.com',
      displayName: 'Usuario Teste',
    );

    // Cria a instância mockada do FirebaseAuth utilizando firebase_auth_mocks
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final sucessSnackbar = find.text('Login efetuado com sucesso!');
    expect(sucessSnackbar, findsOneWidget,
        reason:
            'Checking if the success message is displayed when login is successful');
    final initialPage = find.byKey(const ValueKey('statefulMainPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the user is redirected to the initial page when login is successful');
  });

  testWidgets('Unsuccessfully logged in when user does not exists',
      (WidgetTester tester) async {
    //Given
    // Crie uma instância mock do FirebaseAuth
    final mockAuth = MockFirebaseAuth();

    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'user-not-found'));

    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final userNotFoundMessage =
        find.text('O e-mail informado não foi encontrado.');
    expect(userNotFoundMessage, findsOneWidget,
        reason: 'Checking if the error message is displayed when login fails');
    final initialPage = find.byKey(const ValueKey('statefulLoginPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the page is still the login page when login fails');
  });

  testWidgets('Unsuccessfully logged in when account password is wrong',
      (WidgetTester tester) async {
    //Given
    // Crie uma instância mock do FirebaseAuth
    final mockAuth = MockFirebaseAuth();

    whenCalling(Invocation.method(#signInWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'wrong-password'));

    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final userNotFoundMessage = find.text('Senha incorreta.');
    expect(userNotFoundMessage, findsOneWidget,
        reason: 'Checking if the error message is displayed when login fails');
    final initialPage = find.byKey(const ValueKey('statefulLoginPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the page is still the login page when login fails');
  });

  testWidgets('Successfully registered a new account',
      (WidgetTester tester) async {
    //Given
    final mockCredential = MockUserCredential();
    final MockUser mockUser = MockUser();
    final mockAuth = MockFirebaseAuth(mockUser: mockUser);

    when(mockCredential.user).thenReturn(mockUser);

    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    // Alterando o estado do botão de login para registrar
    Finder switchRegisterButton =
        find.byKey(const ValueKey('buttonLoginRegisterToggle'));
    await tester.tap(switchRegisterButton);
    await tester.pumpAndSettle();
    
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final userNotFoundMessage = find.text('Cadastro efetuado com sucesso!');
    expect(userNotFoundMessage, findsOneWidget,
        reason: 'Checking if the error message is displayed when login fails');
    final initialPage = find.byKey(const ValueKey('statefulMainPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the user is redirected to the initial page when register is successful');
  });

  testWidgets('Unsuccessfully registered a new account when password is weak',
      (WidgetTester tester) async {
    //Given
    final mockAuth = MockFirebaseAuth();

    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'weak-password'));
    
    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    // Alterando o estado do botão de login para registrar
    Finder switchRegisterButton =
        find.byKey(const ValueKey('buttonLoginRegisterToggle'));
    await tester.tap(switchRegisterButton);
    await tester.pumpAndSettle();
    
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final weakPasswordErrorMessage = find.text('A senha informada é muito fraca.');
    expect(weakPasswordErrorMessage, findsOneWidget,
        reason: 'Checking if the error message is displayed when register fails');
    final initialPage = find.byKey(const ValueKey('statefulLoginPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the page is still the login page when register fails');
  });

  testWidgets('Unsuccessfully registered a new account when email is already in use',
      (WidgetTester tester) async {
    //Given
    final mockAuth = MockFirebaseAuth();

    whenCalling(Invocation.method(#createUserWithEmailAndPassword, null))
        .on(mockAuth)
        .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
    
    Widget loginPage = ChangeNotifierProvider(
      create: (context) => AuthService(auth: mockAuth),
      child: const MaterialApp(home: AuthCheck()),
    );
    await tester.pumpWidget(loginPage);
    await tester.pumpAndSettle();
    // Alterando o estado do botão de login para registrar
    Finder switchRegisterButton =
        find.byKey(const ValueKey('buttonLoginRegisterToggle'));
    await tester.tap(switchRegisterButton);
    await tester.pumpAndSettle();
    
    Finder emailFinder = find.byKey(const ValueKey('formFieldEmail'));
    await tester.enterText(emailFinder, 'teste@teste.com');

    Finder passwordFinder = find.byKey(const ValueKey('formFieldPassword'));
    await tester.enterText(passwordFinder, 'teste123');

    // When
    Finder loginButton =
        find.byKey(const ValueKey('buttonLoginRegisterAction'));
    await tester.tap(loginButton);
    await tester.pump(const Duration(milliseconds: 1000));

    //Then
    final emailInUseErrorMessage = find.text('O e-mail informado já está em uso.');
    expect(emailInUseErrorMessage, findsOneWidget,
        reason: 'Checking if the error message is displayed when register fails');
    final initialPage = find.byKey(const ValueKey('statefulLoginPage'));
    expect(initialPage, findsOneWidget,
        reason:
            'Checking if the page is still the login page when register fails');
  });
}
