import 'package:fin_fit_app_mobile/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login page displays correctly', (WidgetTester tester) async {
    //Given
    Widget loginPage = const MaterialApp(home: LoginPage());
    
    // When
    await tester.pumpWidget(
      loginPage
    );

    //Then
    expect(find.text('Bem-vindo!'), findsOne,
        reason: 'Checking if the welcome title is displayed correctly when page is loaded');
    expect(find.text('Login'), findsOne,
        reason: 'Checking if the login button text is displayed correctly when page is loaded');
    expect(find.text('Ainda não tem uma conta? Cadastre-se agora!'), findsOne,
        reason: 'Checking if the toggle button text is displayed correctly when page is loaded');

    expect(find.byKey(const ValueKey('formFieldEmail')), findsOne,
        reason: 'Checking if the email form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('formFieldPassword')), findsOne,
        reason: 'Checking if the password form field is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterAction')), findsOne,
        reason: 'Checking if the login or register button is displayed correctly when page is loaded');
    expect(find.byKey(const ValueKey('buttonLoginRegisterToggle')), findsOne,
        reason: 'Checking if the toggle button is displayed correctly when page is loaded');
  });
}
