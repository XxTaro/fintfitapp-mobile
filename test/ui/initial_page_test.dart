import 'package:fin_fit_app_mobile/ui/initial_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

void main() {
  testWidgets('Checking if MainPage displays correctly', (WidgetTester tester) async {
    //Given
    Widget initialPage = const MaterialApp(home: InitialPage(title: 'FinFitApp'));
    
    // When
    await tester.pumpWidget(
      initialPage
    );

    //Then
    expect(find.byKey(const ValueKey('statefulMainPage')), findsExactly(1),
        reason: 'Checking if the main page is displayed when initial page is loaded');
    expect(find.byKey(const ValueKey('statefulTransactionPage')), findsNothing,
        reason: 'Checking if the transaction page is NOT displayed when initial page is loaded');
    expect(find.byKey(const ValueKey('statefulMenuPage')), findsNothing,
        reason: 'Checking if the menu page is NOT displayed when initial page is loaded');
    expect(find.byKey(const ValueKey('statefulChatPage')), findsNothing,
        reason: 'Checking if the chat page is NOT displayed when initial page is loaded');

    expect(find.byKey(const ValueKey('navHome')), findsExactly(1),
        reason:
            'Checking if the home item is displayed in the bottom navigation bar');
    expect(find.text('Início'), findsExactly(1),
        reason:
            'Checking if the home text is displayed in the bottom navigation bar');
    expect(find.byIcon(Icons.home), findsExactly(1),
        reason:
            'Checking if the home icon is displayed in the bottom navigation bar');

    expect(find.byKey(const ValueKey('navTransaction')), findsExactly(1),
        reason:
            'Checking if the transaction item is displayed in the bottom navigation bar');
    expect(find.text('Transações'), findsExactly(1),
        reason:
            'Checking if the transaction text is displayed in the bottom navigation bar');
    expect(find.byIcon(Icons.receipt_long), findsExactly(1),
        reason:
            'Checking if the transaction icon is displayed in the bottom navigation bar');

    expect(find.byKey(const ValueKey('navGoals')), findsExactly(1),
        reason:
            'Checking if the goal item is displayed in the bottom navigation bar');
    expect(find.text('Metas'), findsExactly(1),
        reason:
            'Checking if the goal text is displayed in the bottom navigation bar');
    expect(
        find.byWidgetPredicate((widget) =>
            widget is Icon &&
            widget.icon == Symbols.target &&
            widget.weight == 700),
        findsExactly(1),
        reason:
            'Checking if the goal icon is displayed in the bottom navigation bar');

    expect(find.byKey(const ValueKey('navMenu')), findsExactly(1),
        reason:
            'Checking if the menu item is displayed in the bottom navigation bar');
    expect(find.text('Menu'), findsExactly(1),
        reason:
            'Checking if the menu text is displayed in the bottom navigation bar');
    expect(find.byIcon(Icons.menu), findsExactly(1),
        reason:
            'Checking if the menu icon is displayed in the bottom navigation bar');
  });

  testWidgets('Checking if MainPage displays transactions page when it menu icon is tapped', (WidgetTester tester) async {
    //Given
    Widget initialPage = const MaterialApp(home: InitialPage(title: 'FinFitApp'));
    
    // When
    await tester.pumpWidget(
      initialPage
    );
    Finder finder = find.byKey(const ValueKey('navTransaction'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();

    //Then
    expect(find.byKey(const ValueKey('statefulTransactionPage')), findsExactly(1),
        reason:
            'Checking if the transaction page is displayed when it menu icon is tapped');
  });

  testWidgets('Checking if MainPage displays menu page when it icons is tapped', (WidgetTester tester) async {
    //Given
    Widget initialPage = const MaterialApp(home: InitialPage(title: 'FinFitApp'));
    
    // When
    await tester.pumpWidget(
      initialPage
    );
    Finder finder = find.byKey(const ValueKey('navMenu'));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();


    //Then
    expect(find.byKey(const ValueKey('statefulMenuPage')), findsExactly(1),
        reason:
            'Checking if the main page is displayed when it menu icon is tapped');
  });
}
