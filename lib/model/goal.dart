class Goal {
  final int id;
  final String description;
  final int value;
  final int categoryId;
  final DateTime dateStart;
  final DateTime dateEnd;

  const Goal({
    required this.id,
    required this.description,
    required this.value,
    required this.categoryId,
    required this.dateStart,
    required this.dateEnd
  });

  factory Goal.fromJson(Map<String, dynamic> data) => Goal(
    id: data['id'],
    description: data['description'],
    value: data['value'],
    categoryId: data['categoryId'],
    dateStart: DateTime.parse(data['dateStart']),
    dateEnd: DateTime.parse(data['dateEnd'])
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'value': value,
    'categoryId': categoryId,
    'dateStart': dateStart.toIso8601String(),
    'dateEnd': dateEnd.toIso8601String()
  };
}