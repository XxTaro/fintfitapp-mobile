import 'package:fin_fit_app_mobile/model/goal.dart';
import 'package:drift/drift.dart';

import '../service/database.dart';

part 'goal_table_helper.g.dart';

@DriftAccessor(tables: [Goal])
class GoalTableHelper extends DatabaseAccessor<Database> with _$GoalTableHelperMixin {
  GoalTableHelper(super.db);

  Future<GoalData?> getById(int id) async {
    return await (select(goal)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<int> addGoal(GoalCompanion entry) async {
    return await into(goal).insert(entry);
  }

  Future<List<GoalData>> getAllGoals() async {
    return await select(goal).get();
  }

  Future<int> deleteGoal(int id) async {
    return await (delete(goal)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<int> updateGoal(GoalCompanion entry) async {
    return await (update(goal)..where((tbl) => tbl.id.equals(entry.id.value))).write(entry);
  }
}