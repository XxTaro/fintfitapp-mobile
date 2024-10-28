import 'package:drift/drift.dart';
import 'package:fin_fit_app_mobile/model/movement.dart';

import '../service/database.dart';

part 'movement_table_helper.g.dart';

@DriftAccessor(tables: [Movement])
class MovementTableHelper extends DatabaseAccessor<Database> with _$MovementTableHelperMixin {
  MovementTableHelper(super.db);

  Future<int> addTransaction(MovementCompanion entry) async {
    return await into(movement).insert(entry);
  }

  Future<List<MovementData>> getByContainsNameAndDate(String name, DateTime date) async {
    return (await (select(movement)..where((tbl) => tbl.description.contains(name) & tbl.timestamp.month.equals(date.month) & tbl.timestamp.year.equals(date.year))).get()).reversed.toList();
  }

  Future<List<MovementData>> getByMonth(DateTime date) async {
    return (await (select(movement)..where((tbl) => tbl.timestamp.month.equals(date.month) & tbl.timestamp.year.equals(date.year))).get()).reversed.toList();
  }
}