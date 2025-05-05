class Expense {
  final String id;
  final double amount;
  final String description;
  final String category;
  final String categoryColor;
  final DateTime date;
  final String userId;

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.category,
    required this.categoryColor,
    required this.date,
    required this.userId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['_id'],
      amount: json['amount'].toDouble(),
      description: json['description'],
      category: json['category'],
      categoryColor: json['categoryColor'],
      date: DateTime.parse(json['date']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'description': description,
      'category': category,
      'categoryColor': categoryColor,
      'date': date.toIso8601String(),
      'userId': userId,
    };
  }
} 