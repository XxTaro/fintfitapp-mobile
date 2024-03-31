import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'my_database.db'),
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE users('
              'id INTEGER PRIMARY KEY, name TEXT, age INTEGER'
              ')',
        );
      },
      version: 1,
    );
  }
}