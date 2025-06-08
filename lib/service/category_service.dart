import 'package:firebase_database/firebase_database.dart';

class CategoryService {
  final FirebaseDatabase _database;

  // Construtor que permite injetar uma instância do Firebase (para testes)
  CategoryService({FirebaseDatabase? database}) 
      : _database = database ?? FirebaseDatabase.instance;

  // Método que busca as categorias iniciais
  Future<List<String>> getCategories() async {
    final categoriesRef = _database.ref('categories');
    try {
      final categoriesSnap = await categoriesRef.get();
      // Lida com o caso de o valor ser nulo ou não ser uma lista
      final value = categoriesSnap.value;
      if (value is List) {
        return value.map((item) => item.toString()).toList();
      }
      return []; // Retorna lista vazia se não for uma lista
    } catch (err) {
      print(err); // Em um app real, use um logger
      return []; // Retorna lista vazia em caso de erro
    }
  }

  // Método que ouve as atualizações
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