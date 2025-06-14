import 'package:firebase_database/firebase_database.dart';

class CategoryService {
  final FirebaseDatabase _database;

  CategoryService({FirebaseDatabase? database}) 
      : _database = database ?? FirebaseDatabase.instance;

  Future<List<String>> getCategories() async {
    final categoriesRef = _database.ref('categories');
    try {
      final categoriesSnap = await categoriesRef.get();
      final value = categoriesSnap.value;
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return [];
    } catch (err) {
      print(err);
      return [];
    }
  }
  
  Stream<List<String>> onCategoriesUpdated() {
    final categoriesRef = _database.ref('categories');
    return categoriesRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return [];
    });
  }
}