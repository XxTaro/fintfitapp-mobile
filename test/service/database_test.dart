import 'package:drift/native.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:fin_fit_app_mobile/service/database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Inicialização do BD', () {

    test('deve preencher a tabela de categorias se ela estiver vazia', () async {
      // Given
      final db = Database.forTesting(NativeDatabase.memory());
      final categoryHelper = CategoryTableHelper(db);

      // When
      await fillCategoryTable(db);

      // Then
      final allCategories = await categoryHelper.getAllCategories();

      expect(allCategories.length, 8);
      final categoryNames = allCategories.map((c) => c.name).toList();
      expect(categoryNames, contains('Alimentação'));
      expect(categoryNames, contains('Moradia'));
      expect(categoryNames, contains('Outros'));

      await db.close();
    });

    test('NÃO deve preencher a tabela de categorias se ela JÁ contiver dados', () async {
      // Given
      final db = Database.forTesting(NativeDatabase.memory());
      final categoryHelper = CategoryTableHelper(db);

      await categoryHelper.addCategory(
        CategoryCompanion.insert(name: 'Existente'),
      );

      // When
      await fillCategoryTable(db);

      // Then
      final allCategories = await categoryHelper.getAllCategories();
      
      expect(allCategories.length, 1);
      expect(allCategories.first.name, 'Existente');

      await db.close();
    });
  });
}