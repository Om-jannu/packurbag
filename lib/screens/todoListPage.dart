import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/todo.dart';
import '../utils/utils.dart';

class TodoListPage extends StatefulWidget {
  final CategoryData category;

  const TodoListPage({Key? key, required this.category}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late List<TodoData> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response = await http.get(
        Uri.parse('http://$serverIp:5000/todos/$userId/${widget.category.sId}'),
      );

      if (response.statusCode == 200) {
        final todo = Todo.fromJson(jsonDecode(response.body));
        if (todo.success ?? false) {
          setState(() {
            _todos = todo.todoData ?? [];
          });
        } else {
          if (mounted) {
            GlobalSnackbar.show(
              context,
              todo.message ?? 'Failed to fetch todos',
            );
          }
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to fetch todos');
        }
      }
    } catch (e) {
      print('Error: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'Connection error: Please check your internet connection.',
          );
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'An error occurred while fetching todos',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.categoryName ?? ''),
      ),
      body: ListView.builder(
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          return _buildTodoItem(todo);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoBottomSheet(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTodoItem(TodoData todo) {
    return ListTile(
      title: Text(todo.text ?? ''),
      subtitle: Text(todo.date ?? ''),
      trailing: Checkbox(
        value: todo.completed ?? false,
        onChanged: (value) {
          // Update todo completion status
          setState(() {
            todo.completed = value;
          });
          // Call API to update todo completion status
          _updateTodoCompletionStatus(
              todo, value!); // Pass the updated completion status
        },
      ),
      onTap: () {
        _showEditTodoBottomSheet(todo);
      },
    );
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    int priorityValue = 0;
    DateTime selectedDate = DateTime.now();

    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add New Todo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Todo Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter todo name';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: priorityValue,
                    onChanged: (int? value) {
                      setState(() {
                        priorityValue = value ?? 0;
                      });
                    },
                    items:
                        [0, 1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(priorityLabels[value] ?? 'Unknown'),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Priority'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select priority';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Date:',
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (pickedDate != null &&
                              pickedDate != selectedDate) {
                            setState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Text(
                          DateFormat('yyyy-MM-dd').format(selectedDate),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Call API to add new todo
                            _addTodoData(nameController.text, selectedDate,
                                priorityValue);

                            // Close the bottom sheet
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addTodoData(String text, DateTime date, int priority) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      final response = await http.post(
        Uri.parse('http://$serverIp:5000/todos/$userId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'text': text.trim(),
          'date': date.toIso8601String(),
          'priority': priority,
          'category': widget.category.categoryName,
          'dateOfCreation': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        // Refresh categories after adding
        _fetchTodos();
        if (mounted) {
          GlobalSnackbar.show(context, 'Todo Added successfully',
              success: true);
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to add todo');
        }
      }
    } catch (e) {
      print('Error adding todo: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'Connection error: Please check your internet connection.',
          );
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'An error occurred while adding todo',
          );
        }
      }
    }
  }

  void _showEditTodoBottomSheet(TodoData todo) {
    TextEditingController textController =
        TextEditingController(text: todo.text);
    TextEditingController dateController =
        TextEditingController(text: todo.date);
    int? priorityValue = todo.priority;

    final _formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Todo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: textController,
                    decoration: const InputDecoration(labelText: 'Todo Text'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter todo text';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: priorityValue,
                    onChanged: (int? value) {
                      setState(() {
                        priorityValue = value;
                      });
                    },
                    items:
                        [0, 1, 2, 3, 4].map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(priorityLabels[value] ?? 'Unknown'),
                      );
                    }).toList(),
                    decoration: const InputDecoration(labelText: 'Priority'),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select priority';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Update todo data
                            todo.text = textController.text;
                            todo.date = dateController.text;
                            todo.priority = priorityValue;
                            _updateTodoData(todo);
                            // Close the bottom sheet
                            Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Delete todo
                          _deleteTodoData(todo);

                          // Close the bottom sheet
                          Navigator.pop(context);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _updateTodoCompletionStatus(
      TodoData todo, bool completedStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response = await http.put(
        Uri.parse(
            'http://$serverIp:5000/todos/$userId/${todo.sId}/completedStatus'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'completed': completedStatus,
          'todo':
              todo.toJson(), // Pass the todo along with the completion status
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Update the todo in the list
          final index = _todos.indexWhere((element) => element.sId == todo.sId);
          if (index != -1) {
            _todos[index].completed = completedStatus;
          }
        });
      } else {
        if (mounted) {
          GlobalSnackbar.show(
              context, 'Failed to update todo completion status');
        }
      }
    } catch (e) {
      print('Error updating todo completion status: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'Connection error: Please check your internet connection.',
          );
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'An error occurred while updating todo completion status',
          );
        }
      }
    }
  }

  Future<void> _updateTodoData(TodoData todo) async {
    print(todo.toJson());
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response = await http.put(
        Uri.parse('http://$serverIp:5000/todos/$userId/${todo.sId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode == 200) {
        // Update successful, no need to parse response
        setState(() {
          // Update the todo in the list
          final index = _todos.indexWhere((element) => element.sId == todo.sId);
          if (index != -1) {
            _todos[index] = todo; // Update with the modified todo
          }
          if (mounted) {
            GlobalSnackbar.show(context, 'todo updated successfully',
                success: true);
          }
        });
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to update todo');
        }
      }
    } catch (e) {
      print('Error updating todo: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'Connection error: Please check your internet connection.',
          );
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'An error occurred while updating todo',
          );
        }
      }
    }
  }

  Future<void> _deleteTodoData(TodoData todo) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response = await http.delete(
        Uri.parse('http://$serverIp:5000/todos/$userId/${todo.sId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          // Remove the deleted todo from the list
          _todos.removeWhere((element) => element.sId == todo.sId);
        });
        if (mounted) {
          GlobalSnackbar.show(context, 'todo deleted successfully',
              success: true);
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to delete todo');
        }
      }
    } catch (e) {
      print('Error deleting todo: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'Connection error: Please check your internet connection.',
          );
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
            context,
            'An error occurred while deleting todo',
          );
        }
      }
    }
  }
}
