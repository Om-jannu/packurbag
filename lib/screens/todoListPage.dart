import 'dart:convert';
import 'dart:io';

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/todo.dart';
import '../utils.dart';

class TodoListPage extends StatefulWidget {
  final CategoryData category;

  const TodoListPage({Key? key, required this.category}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  late List<TodoData> _todos = [];
  String _searchText = ''; // Variable to store user's search query
  bool _isSearching = false;
  int _selectedPriorityFilter = -1;
  bool _showInComplete = false;
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
// Filter todos based on search text, selected priority filter, and completed tasks visibility
    List<TodoData> filteredTodos = _todos.where((todo) {
      return (todo.text!.toLowerCase().contains(_searchText.toLowerCase())) &&
          ((todo.priority == _selectedPriorityFilter) ||
              (_selectedPriorityFilter == -1)) &&
          (!_showInComplete || !todo.completed!);
    }).toList();

    // Group todos by date
    Map<String, List<TodoData>> groupedTodos = {};
    filteredTodos.forEach((todo) {
      final todoDate = todo.date!.substring(0, 10);
      groupedTodos.putIfAbsent(todoDate, () => []);
      groupedTodos[todoDate]!.add(todo);
    });

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search todos...',
                  border: InputBorder.none,
                ),
              )
            : Text(
                widget.category.categoryName.capitalizeMaybeNull ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
        shadowColor: _parseColor(widget.category.categoryColor),
        backgroundColor: _parseColor(widget.category.categoryColor),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                // Clear search text when exiting search mode
                if (!_isSearching) {
                  _searchText = '';
                }
              });
            },
          ),
          PopupMenuButton<int>(
            onSelected: (value) {
              setState(() {
                _selectedPriorityFilter = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: -1,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.inbox,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text('All'),
                    ],
                  )),
              const PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.spinner,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 5),
                      Text('Trivial'),
                    ],
                  )),
              const PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.anglesDown,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 5),
                      Text('Low'),
                    ],
                  )),
              const PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.water,
                        color: Colors.yellow,
                      ),
                      SizedBox(width: 5),
                      Text('Neutral'),
                    ],
                  )),
              const PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.anglesUp,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 5),
                      Text('High'),
                    ],
                  )),
              const PopupMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      FaIcon(
                        size: 15,
                        FontAwesomeIcons.triangleExclamation,
                        color: Colors.red,
                      ),
                      SizedBox(width: 5),
                      Text('Critical'),
                    ],
                  )),
            ],
          ),
          Switch(
            activeColor: _parseColor(widget.category.categoryColor),
            activeTrackColor: Colors.black,
            inactiveTrackColor: Colors.black,
            inactiveThumbColor: _parseColor(widget.category.categoryColor),
            value: _showInComplete,
            onChanged: (value) {
              setState(() {
                _showInComplete = value;
              });
            },
          ),
        ],
      ),
      body: groupedTodos.isEmpty
          ? const Center(
              child: Text('No todos found'),
            )
          : ListView.builder(
              itemCount: groupedTodos.length,
              itemBuilder: (context, index) {
                final date = groupedTodos.keys.toList()[index];
                final todos = groupedTodos[date];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 15.0),
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Text(
                            formattedDate(date),
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  left: 10.0, right: 15.0),
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todos!.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return _buildTodoItem(todo);
                      },
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: _parseColor(widget.category.categoryColor),
        onPressed: () {
          _showAddTodoBottomSheet(context);
        },
        child: const FaIcon(
          FontAwesomeIcons.penToSquare,
          size: 20,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTodoItem(TodoData todo) {
    if (_showInComplete && todo.completed!) {
      return const SizedBox(); // Hide completed tasks when the toggle is off
    }
    return ListTile(
      onTap: () => _showEditTodoBottomSheet(todo),
      horizontalTitleGap: 5,
      leading: Transform.scale(
        scale: 1.2,
        child: Checkbox(
          side: BorderSide(color: _parseColor(widget.category.categoryColor)),
          activeColor: Colors.transparent,
          checkColor: _parseColor(widget.category.categoryColor),
          shape: const CircleBorder(),
          value: todo.completed,
          onChanged: (bool? value) async {
            _updateTodoCompletionStatus(todo, value!);
            setState(() {
              todo.completed = value;
            });
          },
        ),
      ),
      title: Text(
        todo.text ?? '',
        style: TextStyle(
          color: todo.completed! ? Colors.grey[600] : Colors.white,
        ),
      ),
      subtitle: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: _parseColor(widget.category.categoryColor),
            ),
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            child: Text(
              todo.category.capitalizeMaybeNull ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              _getPriorityIcon(todo.priority!),
              const SizedBox(width: 4),
              Text(
                priorityLabels[todo.priority] ?? 'Unknown',
                style: TextStyle(
                  color: _getPriorityIconColor(todo.priority!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTodoBottomSheet(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    int priorityValue = 0;
    DateTime selectedDate = DateTime.now(); // Initialize selected date here

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
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
                              selectedDate =
                                  pickedDate; // Update selected date here
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
                          if (formKey.currentState!.validate()) {
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
      print(date);

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

  Color _getPriorityIconColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.blueGrey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  FaIcon _getPriorityIcon(int priority) {
    switch (priority) {
      case 0:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.spinner,
          color: Colors.blueGrey,
        );
      case 1:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesDown,
          color: Colors.blue,
        );
      case 2:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.water,
          color: Colors.yellow,
        );
      case 3:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesUp,
          color: Colors.orange,
        );
      case 4:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.triangleExclamation,
          color: Colors.red,
        );
      default:
        return const FaIcon(
          FontAwesomeIcons.question,
          color: Colors.grey,
        );
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return Color(int.parse('0xFF$colorHex'));
    }
    return Colors.grey;
  }

  void _showEditTodoBottomSheet(TodoData todo) {
    TextEditingController textController =
        TextEditingController(text: todo.text);
    TextEditingController dateController =
        TextEditingController(text: todo.date);
    int? priorityValue = todo.priority;

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
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
                          if (formKey.currentState!.validate()) {
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
