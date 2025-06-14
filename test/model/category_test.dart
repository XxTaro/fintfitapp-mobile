import 'package:drift/native.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/service/database.dart' as db;

void main() {
  late Database dbInstance;
  late CategoryTableHelper categoryHelper;

  test.setUp(() {
    dbInstance = db.Database.forTesting(NativeDatabase.memory());
    categoryHelper = CategoryTableHelper(dbInstance);
  });

  test.tearDown(() async {
    await dbInstance.close();
  });

  test.group('Testes de CRUD do CategoryTableHelper', () {

    test.test('deve adicionar uma nova categoria e recuperá-la pelo id', () async {
      // Given
      final newCategory = CategoryCompanion.insert(name: 'Alimentação');

      // When
      final generatedId = await categoryHelper.addCategory(newCategory);
      final foundCategory = await categoryHelper.getById(generatedId);

      // Then
      test.expect(foundCategory.id, generatedId);
      test.expect(foundCategory.name, 'Alimentação');
    });

    test.test('deve retornar todas as categorias cadastradas', () async {
      // Given
      await categoryHelper.addCategory(CategoryCompanion.insert(name: 'Lazer'));
      await categoryHelper.addCategory(CategoryCompanion.insert(name: 'Transporte'));

      // When
      final allCategories = await categoryHelper.getAllCategories();

      // Then
      test.expect(allCategories.length, 2);
      test.expect(allCategories.map((c) => c.name), test.containsAll(['Lazer', 'Transporte']));
    });

    test.test('deve encontrar uma categoria pelo nome', () async {
      // Given
      await categoryHelper.addCategory(CategoryCompanion.insert(name: 'Saúde'));

      // When
      final foundCategory = await categoryHelper.getByName('Saúde');

      // Then
      test.expect(foundCategory, test.isNotNull);
      test.expect(foundCategory!.name, 'Saúde');
    });

    test.test('deve retornar nulo ao procurar por um nome que não existe', () async {
      // When
      final foundCategory = await categoryHelper.getByName('Inexistente');

      // Then
      test.expect(foundCategory, test.isNull);
    });

    test.test('deve atualizar uma categoria pelo seu id', () async {
      // Given
      final originalCategory = CategoryCompanion.insert(name: 'Moradia');
      final id = await categoryHelper.addCategory(originalCategory);

      // When
      const updatedCompanion = CategoryCompanion(name: Value('Habitação'));
      await categoryHelper.updateCategoryById(updatedCompanion, id);
      final fetchedCategory = await categoryHelper.getById(id);

      // Then
      test.expect(fetchedCategory.name, 'Habitação');
      test.expect(fetchedCategory.id, id);
    });
    
    test.test('deve deletar uma categoria pelo id', () async {
      // Given
      final id = await categoryHelper.addCategory(CategoryCompanion.insert(name: 'Educação'));
      
      // When
      await categoryHelper.deleteCategory(id);
      
      // Then
      test.expect(
        () => categoryHelper.getById(id),
        test.throwsA(test.isA<StateError>()),
      );
    });
  });

  test.group('Testes de Validação do Model (via Helper)', () {
    
    test.test('deve falhar ao adicionar categoria com nome vazio', () {
      // Given
      final invalidCategory = CategoryCompanion.insert(name: '');

      // When & Then
      test.expect(
        () => categoryHelper.addCategory(invalidCategory),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });

    test.test('deve falhar ao adicionar categoria com nome muito longo', () {
      // Given
      final longName = 'a' * 21;
      final invalidCategory = CategoryCompanion.insert(name: longName);

      // When & Then
      test.expect(
        () => categoryHelper.addCategory(invalidCategory),
        test.throwsA(test.isA<InvalidDataException>()),
      );
    });
  });
}