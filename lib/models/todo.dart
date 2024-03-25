class Todo {
  bool? success;
  String? message;
  List<TodoData>? todoData;

  Todo({this.success, this.message, this.todoData});

  Todo.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      if (json['data'] is List) {
        print("data is list");
        // If 'data' is a list, assume it contains todo items
        todoData = (json['data'] as List)
            .map((item) => TodoData.fromJson(item))
            .toList();
      } else if (json['data'] is Map) {
        print("data is map");
        // If 'data' is a map, assume it's a single todo item
        todoData = [TodoData.fromJson(json['data'])];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> todoData = new Map<String, dynamic>();
    todoData['success'] = this.success;
    todoData['message'] = this.message;
    if (this.todoData != null) {
      todoData['data'] = this.todoData!.map((v) => v.toJson()).toList();
    }
    return todoData;
  }
}

class TodoData {
  String? text;
  String? date;
  bool? completed;
  int? priority;
  String? category;
  String? dateOfCreation;
  String? sId;

  TodoData(
      {this.text,
      this.date,
      this.completed,
      this.priority,
      this.category,
      this.dateOfCreation,
      this.sId});

  TodoData.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    date = json['date'];
    completed = json['completed'];
    priority = json['priority'];
    category = json['category'];
    dateOfCreation = json['dateOfCreation'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> todoData = new Map<String, dynamic>();
    todoData['text'] = this.text;
    todoData['date'] = this.date;
    todoData['completed'] = this.completed;
    todoData['priority'] = this.priority;
    todoData['category'] = this.category;
    todoData['dateOfCreation'] = this.dateOfCreation;
    todoData['_id'] = this.sId;
    return todoData;
  }
}
