class Event {
  final String text;
  final DateTime date;
  bool completed;
  final int priority;
  final String category;
  final String categoryColor;
  final DateTime dateOfCreation;
  final String id;

  Event({
    required this.text,
    required this.date,
    required this.completed,
    required this.priority,
    required this.category,
    required this.categoryColor,
    required this.dateOfCreation,
    required this.id,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      text: json['text'] ?? '',
      date: DateTime.parse(json['date'] ?? ''),
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 0,
      category: json['category'] ?? '',
      categoryColor: json['categoryColor'] ?? '',
      dateOfCreation: DateTime.parse(json['dateOfCreation'] ?? ''),
      id: json['_id'] ?? '',
    );
  }

  @override
  String toString() => text;
}
