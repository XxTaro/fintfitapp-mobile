import 'package:firebase_auth/firebase_auth.dart';
import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/ui/auth_check.dart';
import 'package:fin_fit_app_mobile/ui/initial_page.dart';
import 'package:fin_fit_app_mobile/ui/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'auth_check_test.mocks.dart';

Widget createAuthCheckScreen(MockAuthService mockAuthService) {
  return ChangeNotifierProvider<AuthService>.value(
    value: mockAuthService,
    child: const MaterialApp(
      home: AuthCheck(),
    ),
  );
}

@GenerateMocks([AuthService, User])
void main() {
  late MockAuthService mockAuthService;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    mockUser = MockUser();
  });

  testWidgets('deve mostrar CircularProgressIndicator quando isLoading é true', (WidgetTester tester) async {
    // Given
    when(mockAuthService.isLoading).thenReturn(true);

    // When
    await tester.pumpWidget(createAuthCheckScreen(mockAuthService));

    // Then
    final loadingFinder = find.byKey(const ValueKey("authLoadingProgressIndicator"));
    
    expect(loadingFinder, findsOneWidget);
    expect(find.byType(LoginPage), findsNothing);
    expect(find.byType(InitialPage), findsNothing);
  });

  testWidgets('deve mostrar LoginPage quando o usuário está deslogado', (WidgetTester tester) async {
    // Given
    when(mockAuthService.isLoading).thenReturn(false);
    when(mockAuthService.currentUser).thenReturn(null);

    // When
    await tester.pumpWidget(createAuthCheckScreen(mockAuthService));
    
    // Then
    final loginPageFinder = find.byKey(const ValueKey('statefulLoginPage'));

    expect(loginPageFinder, findsOneWidget);
    expect(find.byKey(const ValueKey("authLoadingProgressIndicator")), findsNothing);
    expect(find.byType(InitialPage), findsNothing);
  });

  testWidgets('deve mostrar InitialPage quando o usuário está logado', (WidgetTester tester) async {
    // Given
    when(mockAuthService.isLoading).thenReturn(false);
    when(mockAuthService.currentUser).thenReturn(mockUser);

    // When
    await tester.pumpWidget(createAuthCheckScreen(mockAuthService));

    // Then
    final initialPageFinder = find.byType(InitialPage);

    expect(initialPageFinder, findsOneWidget);
    expect(find.byKey(const ValueKey("authLoadingProgressIndicator")), findsNothing);
    expect(find.byType(LoginPage), findsNothing);
  });
}