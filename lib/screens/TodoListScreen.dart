import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListScreen extends StatefulWidget {
  final String category;

  TodoListScreen({required this.category, var serverIp});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<TodoItem> todos = [];
  bool isLoading = false;

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
      Uri.parse('http://$serverIp:5000/get_todos'),
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
          setState(() {
            // Populate the todos list with TodoItem objects
            todos = List<TodoItem>.from(data['todos'].map(
              (todo) => TodoItem(
                text: todo['text'],
                date: DateTime.parse(todo['date']),
                isChecked: false,
              ),
            ));
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
      Uri.parse('http://$serverIp:5000/add_todo'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': widget.category,
        'todo': todo,
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
      Uri.parse('http://$serverIp:5000/edit_todo'),
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
      Uri.parse('http://$serverIp:5000/delete_todo'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          todos[index].text,
                          style: todos[index].isChecked
                              ? TextStyle(decoration: TextDecoration.lineThrough)
                              : null,
                        ),
                        subtitle: Text('Date: ${todos[index].formattedDate}'),
                        leading: Checkbox(
                          value: todos[index].isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              todos[index].isChecked = value ?? false;
                            });
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                // Display a confirmation dialog
                                bool confirmDelete = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Todo'),
                                      content: Text(
                                          'Are you sure you want to delete this todo?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false); // Don't delete
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Confirm delete
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                // If the user confirms the delete, then proceed
                                if (confirmDelete == true) {
                                  // Delete todo from the database
                                  deleteTodoFromDatabase(todos[index].text);
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () async {
                                TextEditingController editTodoController =
                                    TextEditingController(
                                        text: todos[index].text);

                                await showDialog<void>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Edit Todo'),
                                      content: TextField(
                                        controller: editTodoController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter new todo...',
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            // Get the new todo
                                            String newTodo =
                                                editTodoController.text;

                                            // Edit the todo in the database
                                            await editTodoInDatabase(
                                                todos[index].text, newTodo);

                                            // Close the dialog
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Edit'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: todoController,
                    decoration: InputDecoration(
                      hintText: 'Enter a new todo...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      addTodoToDatabase(todoController.text);
                      todoController.clear();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
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
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
