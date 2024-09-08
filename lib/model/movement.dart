import 'package:drift/drift.dart';

class Movement extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 20)();
  BoolColumn get isIncome => boolean()();
  RealColumn get value => real()();
  IntColumn get categoryId => integer()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  IntColumn get goalId => integer().nullable()();
}