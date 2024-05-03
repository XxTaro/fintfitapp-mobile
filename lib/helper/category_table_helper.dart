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
}