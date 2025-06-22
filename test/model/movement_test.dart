import 'package:drift/native.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/helper/movement_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/service/database.dart' as db;

void main() {
  late Database dbInstance;
  late MovementTableHelper movementHelper;
  late CategoryTableHelper categoryHelper;
  late int categoryId;

  test.setUp(() async {
    dbInstance = db.Database.forTesting(NativeDatabase.memory());
    movementHelper = MovementTableHelper(dbInstance);
    categoryHelper = CategoryTableHelper(dbInstance);

    categoryId = await categoryHelper.addCategory(
      const CategoryCompanion(name: Value('Geral')),
    );
  });

  test.tearDown(() async {
    await dbInstance.close();
  });

  MovementCompanion createTestMovement({
    required String description,
    required bool isIncome,
    required double value,
    required DateTime timestamp,
  }) {
    return MovementCompanion.insert(
      description: description,
      isIncome: isIncome,
      value: value,
      categoryId: categoryId,
      timestamp: timestamp,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  test.group('Testes de CRUD do MovementTableHelper', () {
    test.test('deve adicionar uma nova transação e conseguir recuperá-la', () async {
      // Given
      final date = DateTime(2025, 6, 15);
      final newMovement = createTestMovement(
        description: 'Salário',
        isIncome: true,
        value: 5000.0,
        timestamp: date,
      );

      // When
      final generatedId = await movementHelper.addTransaction(newMovement);
      final movementsInMonth = await movementHelper.getByMonth(date);

      // Then
      test.expect(movementsInMonth.length, 1);
      test.expect(movementsInMonth.first.id, generatedId);
      test.expect(movementsInMonth.first.description, 'Salário');
      test.expect(movementsInMonth.first.value, 5000.0);
    });

    test.test('deve atualizar uma transação existente', () async {
      // Given
      final date = DateTime(2025, 6, 15);
      final originalMovement = createTestMovement(
        description: 'Aluguel',
        isIncome: false,
        value: 1500.0,
        timestamp: date,
      );
      final id = await movementHelper.addTransaction(originalMovement);

      // When
      final updatedMovement = MovementCompanion(
        id: Value(id),
        description: const Value('Aluguel Corrigido'),
        value: const Value(1550.0)
      );
      await movementHelper.updateTransaction(updatedMovement);
      final movementsInMonth = await movementHelper.getByMonth(date);

      // Then
      test.expect(movementsInMonth.first.description, 'Aluguel Corrigido');
      test.expect(movementsInMonth.first.value, 1550.0);
    });

    test.test('deve deletar uma transação', () async {
      // Given
      final date = DateTime(2025, 6, 15);
      final movement = createTestMovement(
        description: 'Para Deletar',
        isIncome: false,
        value: 10.0,
        timestamp: date,
      );
      final id = await movementHelper.addTransaction(movement);

      // When
      await movementHelper.deleteTransaction(id);
      final movementsInMonth = await movementHelper.getByMonth(date);

      // Then
      test.expect(movementsInMonth, test.isEmpty);
    });

    test.test('deve buscar por parte do nome e data', () async {
      // Given
      final date = DateTime(2025, 7, 10);
      await movementHelper.addTransaction(createTestMovement(description: 'Conta de Luz', isIncome: false, value: 150.0, timestamp: date));
      await movementHelper.addTransaction(createTestMovement(description: 'Conta de Água', isIncome: false, value: 80.0, timestamp: date));
      await movementHelper.addTransaction(createTestMovement(description: 'Supermercado', isIncome: false, value: 600.0, timestamp: date));

      // When
      final results = await movementHelper.getByContainsNameAndDate('Conta', date);

      // Then
      test.expect(results.length, 2);
      test.expect(results[0].description, 'Conta de Água');
      test.expect(results[1].description, 'Conta de Luz');
    });

    test.test('deve buscar por mês e categoria', () async {
      // Given
      final date = DateTime(2025, 8, 1);
      final otherCategoryId = await categoryHelper.addCategory(const CategoryCompanion(name: Value('Lazer')));
      
      await movementHelper.addTransaction(createTestMovement(description: 'Moradia', isIncome: false, value: 1000, timestamp: date));
      
      final otherCategoryMovement = MovementCompanion.insert(
          description: 'Cinema',
          isIncome: false,
          value: 50,
          categoryId: otherCategoryId,
          timestamp: date,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      await movementHelper.addTransaction(otherCategoryMovement);
      
      final categoryToSearch = CategoryData(id: otherCategoryId, name: 'Lazer');

      // When
      final results = await movementHelper.getByMonthAndCategory(date, categoryToSearch);

      // Then
      test.expect(results.length, 1);
      test.expect(results.first.description, 'Cinema');
    });
     test.test('deve retornar todas do mês se categoria for nula', () async {
      // Given
      final date = DateTime(2025, 8, 1);
      final otherCategoryId = await categoryHelper.addCategory(const CategoryCompanion(name: Value('Lazer')));
      
      await movementHelper.addTransaction(createTestMovement(description: 'Moradia', isIncome: false, value: 1000, timestamp: date));
      final otherCategoryMovement = MovementCompanion.insert(
          description: 'Cinema',
          isIncome: false,
          value: 50,
          categoryId: otherCategoryId,
          timestamp: date,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now());
      await movementHelper.addTransaction(otherCategoryMovement);
      
      // When
      final results = await movementHelper.getByMonthAndCategory(date, null);

      // Then
      test.expect(results.length, 2);
    });
  });

  test.group('Testes de Validação do Model (via Helper)', () {
    test.test('deve falhar ao adicionar transação com descrição vazia', () {
      // Given
      final invalidMovement = createTestMovement(
        description: '',
        isIncome: true,
        value: 100,
        timestamp: DateTime.now(),
      );

      // When & Then
      test.expect(
        () => movementHelper.addTransaction(invalidMovement),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });

    test.test('deve falhar ao adicionar transação com descrição mais do que 20', () {
      // Given
      final invalidMovement = createTestMovement(
        description: 'a' * 21,
        isIncome: true,
        value: 100,
        timestamp: DateTime.now(),
      );

      // When & Then
      test.expect(
        () => movementHelper.addTransaction(invalidMovement),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });
  });
}