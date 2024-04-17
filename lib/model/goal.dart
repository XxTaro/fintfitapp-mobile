import 'package:drift/drift.dart';

class Goal extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get description => text().withLength(min: 1, max: 20)();
  IntColumn get value => integer()();
  IntColumn get categoryId => integer()();
  DateTimeColumn get dateStart => dateTime()();
  DateTimeColumn get dateEnd => dateTime()();

  // const Goal({
  //   required this.id,
  //   required this.description,
  //   required this.value,
  //   required this.categoryId,
  //   required this.dateStart,
  //   required this.dateEnd
  // });
  //
  // factory Goal.fromJson(Map<String, dynamic> data) => Goal(
  //   id: data['id'],
  //   description: data['description'],
  //   value: data['value'],
  //   categoryId: data['categoryId'],
  //   dateStart: DateTime.parse(data['dateStart']),
  //   dateEnd: DateTime.parse(data['dateEnd'])
  // );
  //
  // Map<String, dynamic> toMap() => {
  //   'id': id,
  //   'description': description,
  //   'value': value,
  //   'categoryId': categoryId,
  //   'dateStart': dateStart.toIso8601String(),
  //   'dateEnd': dateEnd.toIso8601String()
  // };
}