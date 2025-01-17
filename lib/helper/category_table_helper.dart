import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/model/category.dart';

import '../service/database.dart';

part 'category_table_helper.g.dart';

@DriftAccessor(tables: [Category])
class CategoryTableHelper extends DatabaseAccessor<Database> with _$CategoryTableHelperMixin {
  CategoryTableHelper(super.db);

  // returns the generated id
  Future<int> addCategory(CategoryCompanion entry) async {
    return await into(category).insert(entry);
  }

  Future<List<CategoryData>> getAllCategories() async {
    return await select(category).get();
  }

  Future<CategoryData> getById(int id) async {
    return await (select(category)..where((tbl) => tbl.id.equals(id))).getSingle();
  }

  Future<CategoryData?> getByName(String name) async {
    return await (select(category)..where((tbl) => tbl.name.equals(name))).getSingleOrNull();
  }

  Future<void> updateCategory(CategoryCompanion entry) async {
    await (update(category)..where((tbl) => tbl.name.equals(entry.name.value))).write(entry);
  }

  Future<void> updateCategoryById(CategoryCompanion entry, int id) async {
    await (update(category)..where((tbl) => tbl.id.equals(id))).write(entry);
  }

  Future<void> deleteCategory(int id) async {
    await (delete(category)..where((tbl) => tbl.id.equals(id))).go();
  }
}