import 'package:fin_fit_app_mobile/ui/menu_page.dart';
import 'package:fin_fit_app_mobile/ui/personalize_category_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('', (WidgetTester tester) async {
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

  testWidgets('Check MenuItems enum fields',  (WidgetTester tester) async {
    expect(MenuItems.values.length, 1);
    expect(MenuItems.values[0].title, 'Personalizar categorias');
    expect(MenuItems.values[0].description, 'Criar, editar ou remover categorias');
    expect(MenuItems.values[0].icon.toString(), const Icon(Icons.edit).toString());
    expect(MenuItems.values[0].page.toString(), const PersonalizeCategoryPage().toString());
  });
}