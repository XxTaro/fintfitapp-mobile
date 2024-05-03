import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fin_fit_app_mobile/helper/category_table_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import '../model/category.dart';
import '../model/goal.dart';
import '../model/transaction.dart';

part 'database.g.dart';

class DatabaseConnection {
  static Database? _database;

  DatabaseConnection._();

  static Database get instance {
    return _database ??= Database._();
  }
}

@DriftDatabase(tables: [Category, Goal, Movement])
class Database extends _$Database {

  Database._() : super(_openConnection()) {
    fillCategoryTable(this);
  }

  @override
  int get schemaVersion => 1;
}

void fillCategoryTable(Database db) async {
  CategoryTableHelper categoryTableHelper = CategoryTableHelper(db);
  Future<List<CategoryData>> allCategoriesFuture = categoryTableHelper.getAllCategories();
  List<CategoryData> allCategories = await allCategoriesFuture;
  if (allCategories.isNotEmpty) return;
  final categories = [
    CategoryCompanion.insert(name: 'Alimentação'),
    CategoryCompanion.insert(name: 'Transporte'),
    CategoryCompanion.insert(name: 'Saúde'),
    CategoryCompanion.insert(name: 'Entretenimento'),
    CategoryCompanion.insert(name: 'Educação'),
    CategoryCompanion.insert(name: 'Investimento'),
    CategoryCompanion.insert(name: 'Moradia'),
    CategoryCompanion.insert(name: 'Outros'),
  ];

  for (var category in categories) {
    await categoryTableHelper.addCategory(category);
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // Also work around limitations on old Android versions
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    // Make sqlite3 pick a more suitable location for temporary files - the
    // one from the system may be inaccessible due to sandboxing.
    final cachebase = (await getTemporaryDirectory()).path;
    // We can't access /tmp on Android, which sqlite3 would try by default.
    // Explicitly tell it about the correct temporary directory.
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}