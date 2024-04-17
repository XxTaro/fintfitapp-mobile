import 'package:drift/drift.dart';

class Movement extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 20)();
  IntColumn get value => integer()();
  IntColumn get categoryId => integer()();
  IntColumn get timestamp => integer()();
  IntColumn get goalId => integer()();

  // const Transaction({
  //   required this.id,
  //   required this.description,
  //   required this.value,
  //   required this.categoryId,
  //   required this.timestamp,
  //   required this.goalId
  // });
  //
  // factory Transaction.fromJson(Map<String, dynamic> data) => Transaction(
  //     id: data['id'],
  //     description: data['description'],
  //     value: data['value'],
  //     categoryId: data['categoryId:'],
  //     timestamp: data['timestamp'],
  //     goalId: data['goalId']
  // );
  //
  // Map<String, dynamic> toMap() => {
  //   'id': id,
  //   'description': description,
  //   'value': value,
  //   'categoryId': categoryId,
  //   'timestamp': timestamp,
  //   'goalId': goalId
  // };

}