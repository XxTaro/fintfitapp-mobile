import 'package:drift/drift.dart';

class Category extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();

  // const Category({
  //   required this.id,
  //   required this.name
  // });
  //
  // factory Category.fromJson(Map<String, dynamic> data) => Category(
  //     id: data['id'],
  //     name: data['name']
  // );
  //
  // Map<String, dynamic> toMap() => {
  //   'id': id,
  //   'name': name
  // };
}