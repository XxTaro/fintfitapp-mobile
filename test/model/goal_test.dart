import 'package:drift/native.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/goal_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/service/database.dart' as db;

void main() {
  late Database dbInstance;
  late GoalTableHelper goalHelper;
  late CategoryTableHelper categoryHelper;
  late int categoryId;

  test.setUp(() async {
    dbInstance = db.Database.forTesting(NativeDatabase.memory());
    goalHelper = GoalTableHelper(dbInstance);
    categoryHelper = CategoryTableHelper(dbInstance);

    categoryId = await categoryHelper.addCategory(
      const CategoryCompanion(name: Value('Viagens')),
    );
  });

  test.tearDown(() async {
    await dbInstance.close();
  });

  GoalCompanion createTestGoal({
    required String description,
    required int value,
    required DateTime dateStart,
    required DateTime dateEnd,
  }) {
    return GoalCompanion.insert(
      description: description,
      value: value,
      categoryId: categoryId,
      dateStart: dateStart,
      dateEnd: dateEnd,
    );
  }

  test.group('Testes de CRUD do GoalTableHelper', () {
    test.test('deve retornar uma lista vazia quando não houver metas', () async {
      // When
      final allGoals = await goalHelper.getAllGoals();

      // Then
      test.expect(allGoals, test.isEmpty);
    });

    test.test('deve adicionar uma nova meta e recuperá-la na lista de todas as metas', () async {
      // Given
      final newGoal = createTestGoal(
        description: 'Viagem para a praia',
        value: 2000,
        dateStart: DateTime(2025, 7, 1),
        dateEnd: DateTime(2025, 12, 20),
      );

      // When
      final generatedId = await goalHelper.addGoal(newGoal);
      final allGoals = await goalHelper.getAllGoals();

      // Then
      test.expect(allGoals, test.hasLength(1));
      
      final foundGoal = allGoals.first;
      test.expect(foundGoal.id, generatedId);
      test.expect(foundGoal.description, 'Viagem para a praia');
      test.expect(foundGoal.value, 2000);
      test.expect(foundGoal.categoryId, categoryId);
    });

    test.test('deve retornar todas as metas adicionadas', () async {
      // Given
      await goalHelper.addGoal(createTestGoal(description: 'Meta 1', value: 100, dateStart: DateTime.now(), dateEnd: DateTime.now()));
      await goalHelper.addGoal(createTestGoal(description: 'Meta 2', value: 200, dateStart: DateTime.now(), dateEnd: DateTime.now()));
    
      // When
      final allGoals = await goalHelper.getAllGoals();

      // Then
      test.expect(allGoals, test.hasLength(2));
      test.expect(allGoals.map((g) => g.description), test.containsAll(['Meta 1', 'Meta 2']));
    });
  });

  test.group('Testes de Validação do Model (via Helper)', () {
    test.test('deve falhar ao adicionar meta com descrição vazia', () {
      // Given
      final invalidGoal = createTestGoal(
        description: '',
        value: 100,
        dateStart: DateTime.now(),
        dateEnd: DateTime.now(),
      );

      // When & Then
      test.expect(
        () => goalHelper.addGoal(invalidGoal),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });

    test.test('deve falhar ao adicionar meta com descrição maior que 20 caracteres', () {
      // Given
      final invalidGoal = createTestGoal(
        description: 'a' * 21,
        value: 100,
        dateStart: DateTime.now(),
        dateEnd: DateTime.now(),
      );

      // When & Then
      test.expect(
        () => goalHelper.addGoal(invalidGoal),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });
  });
}