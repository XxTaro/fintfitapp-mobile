import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/goal_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/ui/goal_detail_page.dart';
import 'package:fin_fit_app_mobile/ui/goal_page.dart';
import 'package:mockito/annotations.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'goal_page_test.mocks.dart';

@GenerateMocks([
  MovementTableHelper,
  CategoryTableHelper,
  GoalTableHelper,
])
void main() {
  late MockMovementTableHelper mockMovementTableHelper;
  late MockCategoryTableHelper mockCategoryTableHelper;
  late MockGoalTableHelper mockGoalTableHelper;

  final testGoal1 = GoalData(
    id: 1,
    description: 'Viagem de Férias',
    value: 5000,
    dateStart: DateTime(2025, 1, 1),
    dateEnd: DateTime(2025, 12, 31),
    categoryId: 1,
  );

  final testGoal2 = GoalData(
    id: 2,
    description: 'Comprar Notebook',
    value: 8000,
    dateStart: DateTime(2025, 1, 1),
    dateEnd: DateTime(2026, 12, 31),
    categoryId: 2,
  );

  Future<void> pumpWidget(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GoalPageStateful(
          movementTableHelper: mockMovementTableHelper,
          categoryTableHelper: mockCategoryTableHelper,
          goalTableHelper: mockGoalTableHelper,
        ),
      ),
    );
  }

  setUp(() {
    mockMovementTableHelper = MockMovementTableHelper();
    mockCategoryTableHelper = MockCategoryTableHelper();
    mockGoalTableHelper = MockGoalTableHelper();

    when(mockMovementTableHelper.getByGoalId(any)).thenAnswer((_) async => []);
  });

  testWidgets('Deve exibir o indicador de progresso e depois a lista de metas',
      (tester) async {
    // Given
    when(mockGoalTableHelper.getAllGoals())
        .thenAnswer((_) async => [testGoal1, testGoal2]);

    // When
    await pumpWidget(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Viagem de Férias'), findsOneWidget);
    expect(find.text('Comprar Notebook'), findsOneWidget);
  });

  testWidgets('Deve exibir mensagem quando não houver metas cadastradas',
      (tester) async {
    // Given
    when(mockGoalTableHelper.getAllGoals()).thenAnswer((_) async => []);

    // When
    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Não existem metas cadastradas!'), findsOneWidget);
  });

  testWidgets('Deve navegar para GoalDetailPage ao tocar em uma meta e voltar',
      (tester) async {
    // Given
    when(mockGoalTableHelper.getAllGoals())
        .thenAnswer((_) async => [testGoal1, testGoal2]);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.text('Viagem de Férias'));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(GoalDetailPage), findsOneWidget);
    expect(find.text('Meta: Viagem de Férias'), findsOneWidget);

    // When (voltando)
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Then
    expect(find.byType(GoalDetailPage), findsNothing);
    expect(find.text('Viagem de Férias'), findsOneWidget);
    verify(mockGoalTableHelper.getAllGoals()).called(2);
  });

  testWidgets('Deve adicionar uma nova meta com sucesso', (tester) async {
    // Given
    when(mockGoalTableHelper.getAllGoals()).thenAnswerInOrder([
      Future.value([]),
      Future.value([testGoal1]),
    ]);

    when(mockGoalTableHelper.addGoal(any)).thenAnswer((_) async => 1);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Adicionar Meta'), findsOneWidget);

    // When
    await tester.enterText(
        find.widgetWithText(TextField, 'Descrição'), testGoal1.description);
    await tester.enterText(find.widgetWithText(TextField, 'Valor alvo'),
        testGoal1.value.toString());
    await tester.tap(find.widgetWithText(TextField, 'Data Final'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    // Then
    verify(mockGoalTableHelper.addGoal(any)).called(1);
    expect(find.text('Meta salva!'), findsOneWidget);
    expect(find.text('Viagem de Férias'), findsOneWidget);
  });

  testWidgets('Deve editar uma meta com sucesso', (tester) async {
    // Given
    final updatedGoal = testGoal1.copyWith(description: 'Viagem para a Europa');
    when(mockGoalTableHelper.getAllGoals()).thenAnswerInOrder([
      Future.value([testGoal1]),
      Future.value([updatedGoal]),
    ]);

    when(mockGoalTableHelper.getById(testGoal1.id))
        .thenAnswer((_) async => testGoal1);
    when(mockGoalTableHelper.updateGoal(any)).thenAnswer((_) async => 1);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.longPress(find.text('Viagem de Férias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // Then
    expect(find.text('Editar Meta'), findsOneWidget);

    // When
    await tester.enterText(
        find.widgetWithText(TextField, 'Descrição'), 'Viagem para a Europa');
    await tester.tap(find.text('Editar'));
    await tester.pumpAndSettle();

    // Then
    verify(mockGoalTableHelper.updateGoal(any)).called(1);
    expect(find.text('Meta salva!'), findsOneWidget);
    expect(find.text('Viagem para a Europa'), findsOneWidget);
  });

  testWidgets('Deve deletar uma meta com sucesso', (tester) async {
    // Given
    when(mockGoalTableHelper.getAllGoals()).thenAnswerInOrder([
      Future.value([testGoal1]),
      Future.value([]),
    ]);

    when(mockGoalTableHelper.deleteGoal(testGoal1.id))
        .thenAnswer((_) async => 1);

    await pumpWidget(tester);
    await tester.pumpAndSettle();

    // When
    await tester.longPress(find.text('Viagem de Férias'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deletar'));
    await tester.pumpAndSettle();

    // Then
    expect(
        find.text(
            'Você deseja realmente deletar essa meta?\n\nEssa ação não poderá ser desfeita.'),
        findsOneWidget);

    // When
    await tester.tap(find.widgetWithText(TextButton, 'Sim'));
    await tester.pumpAndSettle();

    // Then
    verify(mockGoalTableHelper.deleteGoal(testGoal1.id)).called(1);
    expect(find.text('Meta deletada!'), findsOneWidget);
    expect(find.text('Não existem metas cadastradas!'), findsOneWidget);
  });
}

extension When<T> on PostExpectation<T> {
  void thenAnswerInOrder(List<T> values) {
    int callCount = 0;
    thenAnswer((_) => values[callCount++]);
  }
}
