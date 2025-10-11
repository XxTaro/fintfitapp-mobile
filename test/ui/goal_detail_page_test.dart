import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/goal_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:fin_fit_app_mobile/ui/goal_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'goal_detail_page_test.mocks.dart';

class MockVoidCallback {
  void call() {}
}

@GenerateMocks([
  MovementTableHelper,
  CategoryTableHelper,
  GoalTableHelper,
  MockVoidCallback
])
void main() {
  late MockMovementTableHelper mockMovementTableHelper;
  late MockCategoryTableHelper mockCategoryTableHelper;
  late MockGoalTableHelper mockGoalTableHelper;
  late MockMockVoidCallback mockOnBack;

  final testGoal = GoalData(
    id: 1,
    description: 'Viagem para a Praia',
    value: 5000,
    dateStart: DateTime(2025, 1, 1),
    dateEnd: DateTime(2025, 12, 31),
    categoryId: 1,
  );

  const testCategory = CategoryData(id: 1, name: 'Viagem');

  final testMovements = [
    MovementData(
        id: 101,
        description: 'Depósito inicial',
        value: 1000.0,
        timestamp: DateTime.now(),
        updatedAt: DateTime.now(),
        isIncome: true,
        categoryId: 1,
        goalId: 1,
        createdAt: DateTime.now()),
    MovementData(
        id: 102,
        description: 'Economia extra',
        value: 500.0,
        timestamp: DateTime.now(),
        updatedAt: DateTime.now(),
        isIncome: true,
        categoryId: 1,
        goalId: 1,
        createdAt: DateTime.now()),
  ];

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GoalDetailPage(
            goal: testGoal,
            onBack: mockOnBack.call,
            movementTableHelper: mockMovementTableHelper,
            categoryTableHelper: mockCategoryTableHelper,
            goalTableHelper: mockGoalTableHelper,
          ),
        ),
      ),
    );
  }

  setUp(() {
    mockMovementTableHelper = MockMovementTableHelper();
    mockCategoryTableHelper = MockCategoryTableHelper();
    mockGoalTableHelper = MockGoalTableHelper();
    mockOnBack = MockMockVoidCallback();

    when(mockCategoryTableHelper.getAllCategories())
        .thenAnswer((_) async => [testCategory]);
    when(mockGoalTableHelper.getAllGoals()).thenAnswer((_) async => [testGoal]);
    when(mockCategoryTableHelper.getById(any))
        .thenAnswer((_) async => testCategory);
    when(mockGoalTableHelper.getById(any)).thenAnswer((_) async => testGoal);
  });

  testWidgets(
      'Deve exibir o indicador de progresso e depois a lista de transações',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => testMovements);

    // When
    await pumpWidget(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Meta: ${testGoal.description}'), findsOneWidget);
    expect(find.text('Depósito inicial'), findsOneWidget);
    expect(find.text('Economia extra'), findsOneWidget);
    expect(find.byType(TransactionListView), findsOneWidget);
  });

  testWidgets(
      'Deve exibir mensagem de "sem transações" quando a lista está vazia',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => []);

    // When
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Não existem transações para esta meta!'), findsOneWidget);
    expect(find.byType(TransactionListView), findsNothing);
  });

  testWidgets('Deve exibir mensagem de erro quando o Future falha',
      (tester) async {
    // Given
    final exception = Exception('Falha no banco de dados');

    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => throw exception);
    when(mockCategoryTableHelper.getAllCategories())
        .thenAnswer((_) async => []);
    when(mockGoalTableHelper.getAllGoals()).thenAnswer((_) async => []);

    // When
    await pumpWidget(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump();

    // Then
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Erro: $exception'), findsOneWidget);
  });

  testWidgets('Deve chamar onBack quando o botão de voltar é pressionado',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => []);
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();

    // Then
    verify(mockOnBack.call()).called(1);
  });

  testWidgets(
      'Deve abrir o diálogo de edição, atualizar a meta e exibir SnackBar de sucesso',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => []);
    final updatedGoalData =
        testGoal.copyWith(description: 'Viagem para a Montanha');
    when(mockGoalTableHelper.updateGoal(any)).thenAnswer((_) async => 1);
    when(mockGoalTableHelper.getById(testGoal.id))
        .thenAnswer((_) async => updatedGoalData);
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
        find.widgetWithText(TextField, 'Viagem para a Praia'), findsOneWidget);

    // When
    await tester.enterText(
        find.widgetWithText(TextField, 'Descrição'), 'Viagem para a Montanha');
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // Then
    verify(mockGoalTableHelper.updateGoal(any)).called(1);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Meta salva!'), findsOneWidget);
    expect(find.text('Meta: Viagem para a Montanha'), findsOneWidget);
  });

  testWidgets('Deve fechar o diálogo de edição de meta ao clicar em Cancelar',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id))
        .thenAnswer((_) async => []);
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(AlertDialog), findsNothing);
    verifyNever(mockGoalTableHelper.updateGoal(any));
  });

  testWidgets('Deve deletar uma transação com sucesso e exibir SnackBar',
      (tester) async {
    // Given
    when(mockMovementTableHelper.getByGoalId(testGoal.id)).thenAnswerInOrder([
      Future.value(testMovements),
      Future.value([testMovements.last]),
      Future.value([testMovements.last]),
    ]);
    when(mockMovementTableHelper.deleteTransaction(testMovements.first.id))
        .thenAnswer((_) async => 1);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();

    // Then
    expect(
        find.text(
            'Você deseja realmente deletar essa transação?\nEssa ação não poderá ser desfeita.'),
        findsOneWidget);

    // When
    await tester.tap(find.text('Sim'));
    await tester.pumpAndSettle();

    // Then
    verify(mockMovementTableHelper.deleteTransaction(testMovements.first.id))
        .called(1);
    expect(find.text('Transação deletada!'), findsOneWidget);
    expect(find.text('Depósito inicial'), findsNothing);
  });

  testWidgets('Deve editar uma transação com sucesso e exibir SnackBar',
      (tester) async {
    // Given
    final originalMovement = testMovements.first;
    final updatedMovement =
        originalMovement.copyWith(description: 'Depósito Corrigido');

    when(mockMovementTableHelper.getByGoalId(testGoal.id)).thenAnswerInOrder([
      Future.value([originalMovement]),
      Future.value([updatedMovement]),
      Future.value([]),
    ]);

    when(mockMovementTableHelper.getById(originalMovement.id))
        .thenAnswer((_) async => originalMovement);
    when(mockMovementTableHelper.updateTransaction(any))
        .thenAnswer((_) async => 1);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byType(InkWell).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Editar Transação'), findsOneWidget);

    // When
    await tester.enterText(
        find.widgetWithText(TextField, 'Descrição'), 'Depósito Corrigido');
    await tester.tap(find.widgetWithText(TextButton, 'Editar'));
    await tester.pumpAndSettle();

    // Then
    final captured =
        verify(mockMovementTableHelper.updateTransaction(captureAny))
            .captured
            .single as MovementCompanion;
    expect(captured.description.value, 'Depósito Corrigido');
    expect(find.text('Transação salva!'), findsOneWidget);
    expect(find.text('Depósito Corrigido'), findsOneWidget);
  });
}

extension When<T> on PostExpectation<T> {
  void thenAnswerInOrder(List<T> values) {
    int callCount = 0;
    thenAnswer((_) => values[callCount++]);
  }
}
