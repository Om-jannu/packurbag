import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/CategoryItem.dart';

class TodoListScreen extends StatefulWidget {
  final String category;
  final String serverIp;

  TodoListScreen({required this.category, required this.serverIp});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  Map<String, List<TodoItem>> todosGroupedByDate = {};
  bool isLoading = false;
  bool showTodayOnly = false;

  TextEditingController todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  Future<void> fetchTodos() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.post(
      Uri.parse('http://${widget.serverIp}:5000/get_todos_by_date'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': widget.category,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        if (data['todos'] != null) {
          // Clear the previous data
          todosGroupedByDate.clear();

          // Populate the todos map with TodoItem objects grouped by date
          data['todos'].forEach((todo) {
            TodoItem todoItem = TodoItem(
              text: todo['text'],
              date: DateTime.parse(todo['date']),
              isChecked: false,
            );

            String formattedDate =
                DateFormat('MMMM d, y').format(todoItem.date);

            if (!todosGroupedByDate.containsKey(formattedDate)) {
              todosGroupedByDate[formattedDate] = [];
            }

            todosGroupedByDate[formattedDate]!.add(todoItem);
          });
        } else {
          // Handle the case where 'todos' is null
          print('Todos list is null');
        }
      } else {
        // Handle the case where 'success' is false
        print('no todos in ' + widget.category);
      }
    } else {
      // Handle error
      print('Failed to fetch todos');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> addTodoToDatabase(String todo) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.post(
      Uri.parse('http://${widget.serverIp}:5000/add_todo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': widget.category,
        'todo': todo,
        'date': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      // Successfully added todo to the database
      print('Todo added to the database');
      fetchTodos(); // Refresh todos after adding a new one
    } else {
      // Handle error
      print('Failed to add todo to the database');
    }
  }

  Future<void> editTodoInDatabase(String oldTodo, String newTodo) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.put(
      Uri.parse('http://${widget.serverIp}:5000/edit_todo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': widget.category,
        'oldTodo': oldTodo,
        'newTodo': newTodo,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully edited todo in the database
      print('Todo edited in the database');
      fetchTodos(); // Refresh todos after editing one
    } else {
      // Handle error
      print('Failed to edit todo in the database');
    }
  }

  Future<void> deleteTodoFromDatabase(String todo) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.delete(
      Uri.parse('http://${widget.serverIp}:5000/delete_todo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': widget.category,
        'todo': todo,
      }),
    );

    if (response.statusCode == 200) {
      // Successfully deleted todo from the database
      print('Todo deleted from the database');
      fetchTodos(); // Refresh todos after deleting one
    } else {
      // Handle error
      print('Failed to delete todo from the database');
    }
  }

  void toggleShowTodayOnly() {
    setState(() {
      showTodayOnly = !showTodayOnly;
    });
  }

  @override
  Widget build(BuildContext context) {
    String backgroundImage = 'assets/custom.png'; // Default image
    // Check if the category is predefined to set a specific image
    if (CategoryItem.predefinedCategories.contains(widget.category)) {
      backgroundImage = CategoryItem.categoryImages[widget.category]!;
    }
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('${widget.category}'),
        actions: [
          IconButton(
            icon: Icon(showTodayOnly
                ? Icons.today_outlined
                : Icons.calendar_month_outlined),
            onPressed: toggleShowTodayOnly,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
            itemCount: showTodayOnly ? 1 : todosGroupedByDate.length,
            itemBuilder: (context, index) {
              if (showTodayOnly) {
                String today =
                    DateFormat('MMMM d, y').format(DateTime.now());
                List<TodoItem>? todos = todosGroupedByDate[today];
          
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        today,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (todos != null)
                      ...todos.map((todo) => ListTile(
                            title: Text(
                              todo.text,
                              style: todo.isChecked
                                  ? TextStyle(
                                      decoration:
                                          TextDecoration.lineThrough)
                                  : null,
                            ),
                            subtitle: Text('Date: ${todo.formattedDate}'),
                            leading: Checkbox(
                              value: todo.isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  todo.isChecked = value ?? false;
                                });
                              },
                            ),
                          )),
                  ],
                );
              } else {
                String date = todosGroupedByDate.keys.elementAt(index);
                List<TodoItem>? todos = todosGroupedByDate[date];
          
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        date,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (todos != null)
                      ...todos.map((todo) => ListTile(
                            title: Text(
                              todo.text,
                              style: todo.isChecked
                                  ? TextStyle(
                                      decoration:
                                          TextDecoration.lineThrough)
                                  : null,
                            ),
                            subtitle: Text('Date: ${todo.formattedDate}'),
                            leading: Checkbox(
                              value: todo.isChecked,
                              onChanged: (bool? value) {
                                setState(() {
                                  todo.isChecked = value ?? false;
                                });
                              },
                            ),
                          )),
                  ],
                );
              }
            },
          ),
    );
  }
}

class TodoItem {
  final String text;
  final DateTime date;
  bool isChecked;

  TodoItem({required this.text, required this.date, required this.isChecked});

  String get formattedDate {
    return DateFormat('MMMM d, y').format(date);
  }
}
