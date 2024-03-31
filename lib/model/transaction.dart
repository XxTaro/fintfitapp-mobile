class Transaction {
  final int id;
  final String description;
  final int value;
  final int categoryId;
  final int timestamp;
  final int goalId;

  const Transaction({
    required this.id,
    required this.description,
    required this.value,
    required this.categoryId,
    required this.timestamp,
    required this.goalId
  });

  factory Transaction.fromJson(Map<String, dynamic> data) => Transaction(
      id: data['id'],
      description: data['description'],
      value: data['value'],
      categoryId: data['categoryId:'],
      timestamp: data['timestamp'],
      goalId: data['goalId']
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'description': description,
    'value': value,
    'categoryId': categoryId,
    'timestamp': timestamp,
    'goalId': goalId
  };

}