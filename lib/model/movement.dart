import 'package:drift/drift.dart';

class Movement extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 20)();
  IntColumn get value => integer()();
  IntColumn get categoryId => integer()();
  DateTimeColumn get timestamp => dateTime()();
  IntColumn get goalId => integer()();
}