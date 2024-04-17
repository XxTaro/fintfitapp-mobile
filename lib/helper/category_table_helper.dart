import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/model/category.dart';

import '../service/database.dart';

part 'category_table_helper.g.dart';

@DriftAccessor(tables: [Category])
class CategoryTableHelper extends DatabaseAccessor<Database> with _$CategoryTableHelperMixin {
  CategoryTableHelper(Database db) : super(db);

  // returns the generated id
  Future<int> addCategory(CategoryCompanion entry) {
    return into(category).insert(entry);
  }
}