import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg_test/flutter_svg_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'main_page_test.mocks.dart';

Widget createMainPageScreen(MovementTableHelper helper) {
  return MaterialApp(
    home: MainPage(movementTableHelper: helper),
  );
}

@GenerateMocks([MovementTableHelper])
void main() {
  late MockMovementTableHelper mockMovementHelper;

  setUpAll(() async {
    await initializeDateFormatting('pt_BR');
  });

  setUp(() {
    mockMovementHelper = MockMovementTableHelper();
  });

  testWidgets(
      'deve mostrar CircularProgressIndicator enquanto os dados estão carregando',
      (tester) async {
    // Given
    when(mockMovementHelper.getByMonth(any)).thenAnswer((_) async => []);

    // When
    await tester.pumpWidget(createMainPageScreen(mockMovementHelper));

    // Then
    expect(find.text('Carregando saldo...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('deve mostrar mensagem de erro se a busca falhar',
      (tester) async {
    // Given
    when(mockMovementHelper.getByMonth(any)).thenThrow(Exception('Falha no DB'));

    // When
    await tester.pumpWidget(createMainPageScreen(mockMovementHelper));
    await tester.pump();

    // Then
    expect(find.text('Erro ao carregar o saldo'), findsOneWidget);
  });

  // Testes de cenários de dados
  testWidgets(
      'deve mostrar saldo positivo e ícone correto quando as entradas são maiores',
      (tester) async {
    // Given
    final mockMovements = [
      MovementData(
          id: 1,
          description: 'Salário',
          isIncome: true,
          value: 5000.0,
          categoryId: 1,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
      MovementData(
          id: 2,
          description: 'Aluguel',
          isIncome: false,
          value: 1500.0,
          categoryId: 2,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    ];
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovements);

    // When
    await tester.pumpWidget(createMainPageScreen(mockMovementHelper));
    await tester.pump();

    // Then
    // Verifica o saldo total (R$ 3.500,00)
    expect(find.textContaining(RegExp(r'R\$\s*3\.500,00')), findsOneWidget);

    // Verifica o total de entradas (R$ 5.000,00)
    expect(find.textContaining(RegExp(r'R\$\s*5\.000,00')), findsOneWidget);

    // Verifica o total de saídas (R$ 1.500,00)
    expect(find.textContaining(RegExp(r'R\$\s*1\.500,00')), findsOneWidget);
    expect(find.svgAssetWithPath('assets/ic_arrow_circle_up_24.svg'),
        findsOneWidget);
    expect(find.svgAssetWithPath('assets/ic_arrow_circle_down_24.svg'),
        findsNothing);
  });

  testWidgets(
      'deve mostrar saldo negativo e ícone correto quando as saídas são maiores',
      (tester) async {
    // Given
    final mockMovements = [
      MovementData(
          id: 1,
          description: 'Bico',
          isIncome: true,
          value: 300.0,
          categoryId: 1,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
      MovementData(
          id: 2,
          description: 'Fatura Cartão',
          isIncome: false,
          value: 1200.0,
          categoryId: 2,
          timestamp: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    ];
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovements);

    // When
    await tester.pumpWidget(createMainPageScreen(mockMovementHelper));
    await tester.pump();

    // Then
    // Verifica o saldo total (-R$ 900,00)
    expect(find.textContaining(RegExp(r'-\sR\$\s*900,00')), findsOneWidget);

    // Verifica o total de entradas (R$ 300,00)
    expect(find.textContaining(RegExp(r'R\$\s*300,00')), findsOneWidget);

    // Verifica o total de saídas (R$ 1.200,00)
    expect(find.textContaining(RegExp(r'R\$\s*1\.200,00')), findsOneWidget);
    expect(find.svgAssetWithPath('assets/ic_arrow_circle_down_24.svg'),
        findsOneWidget);
    expect(find.svgAssetWithPath('assets/ic_arrow_circle_up_24.svg'),
        findsNothing);
  });

  testWidgets(
      'deve mostrar saldo zerado quando a lista de movimentações está vazia',
      (tester) async {
    // Given
    final List<MovementData> mockMovements = [];
    when(mockMovementHelper.getByMonth(any))
        .thenAnswer((_) async => mockMovements);

    // When
    await tester.pumpWidget(createMainPageScreen(mockMovementHelper));
    await tester.pump();

    // Then
    final zeroBalanceFinder = find.textContaining(RegExp(r'R\$\s*0,00'));
    expect(zeroBalanceFinder, findsNWidgets(3)); //Saldo, Entrada e Saída
    expect(find.svgAssetWithPath('assets/ic_arrow_circle_down_24.svg'),
        findsOneWidget);
  });
}
