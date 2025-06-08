import 'package:fin_fit_app_mobile/service/auth_service.dart';
import 'package:fin_fit_app_mobile/ui/menu_page.dart';
import 'package:fin_fit_app_mobile/ui/personalize_category_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(), 
  MockSpec<IAuthService>()
])
void main() {
  testWidgets('Checking if the menu itens is on screen when Menu Page is loaded', (WidgetTester tester) async {
    // Given
    Widget menuPage = const MaterialApp(home: MenuPageState());

    // When
    await tester.pumpWidget(menuPage);
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Personalizar categorias'), findsOne, 
        reason: 'Checking if personalize categories menu text item is present');
    expect(find.text('Criar, editar ou remover categorias'), findsOne,
        reason: 'Checking if personalize categories menu description is present');
    expect(find.byIcon(Icons.edit), findsOne,
        reason: 'Checking if personalize categories menu icon is present');

    expect(find.text('Finalizar sessão'), findsOne,
        reason: 'Checking if logout menu text item is present');
    expect(find.byIcon(Icons.logout), findsOne,
        reason: 'Checking if logout menu icon is present');
  });

  testWidgets('Checking if personalize category page is exhibited when clicked in it item', (WidgetTester tester) async {
    // Given
    MenuPageState menuPageState = const MenuPageState(key: ValueKey('menuPageState'),);
    Widget menuPage = MaterialApp(home: menuPageState);
    await tester.pumpWidget(menuPage);
    await tester.pumpAndSettle();

    // When
    Finder personalizeCatItem = find.text('Personalizar categorias');
    await tester.tap(personalizeCatItem);
    await tester.pump(const Duration(milliseconds: 1000));

    // Then
    expect(find.byType(PersonalizeCategoryPage), findsOne,
        reason: 'Checking if PersonalizeCategoryPage is displayed after tapping menu item');
  });
}