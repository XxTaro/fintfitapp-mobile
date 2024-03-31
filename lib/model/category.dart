class Category {
  final int id;
  final String name;

  const Category({
    required this.id,
    required this.name
  });

  factory Category.fromJson(Map<String, dynamic> data) => Category(
      id: data['id'],
      name: data['name']
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name
  };
}