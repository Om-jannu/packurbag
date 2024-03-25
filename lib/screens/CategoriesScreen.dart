// import 'dart:convert';
// import 'package:flex_color_picker/flex_color_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pub/main.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../components/CategoryItem.dart';
// import '../components/CategoryItemShimmer.dart';
// import 'todoListScreen.dart';

// class CategoryWithTodoCount {
//   final String name;
//   final int todoCount;

//   CategoryWithTodoCount({
//     required this.name,
//     required this.todoCount,
//   });
// }

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({Key? key, var serverIp}) : super(key: key);

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   List<CategoryWithTodoCount> categories = [];
//   bool isLoading = true;
//   bool _isMounted = false;
//   late Color dialogPickerColor;
//   final GlobalKey<FormState> _addCategoryformKey = GlobalKey<FormState>();
//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//     addCategoryToDatabase("premade-Birthdays");
//     addCategoryToDatabase("premade-Shopping");
//     addCategoryToDatabase("premade-Exercise");
//     addCategoryToDatabase("premade-Events");
//     addCategoryToDatabase("premade-Meetings");
//     addCategoryToDatabase("premade-Exams");
//     addCategoryToDatabase("premade-Reading");
//     addCategoryToDatabase("premade-Savings");
//     addCategoryToDatabase("premade-Bills");
//     addCategoryToDatabase("premade-Trips");
//     _loadCategories();
//   }

//   @override
//   void dispose() {
//     _isMounted = false;
//     super.dispose();
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final userId = prefs.getString('userId') ?? '';

//       final response = await http.get(
//         Uri.parse('http://$serverIp:5000/categories/$userId'),
//         headers: {'Content-Type': 'application/json'},
//       );

//       if (_isMounted && response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print(data);
//         if (data['categories'] != null && data['categories'] is List) {
//           List<CategoryWithTodoCount> updatedCategories =
//               List<String>.from(data['categories']).map((category) {
//             int todoCount = 0;

//             // Find the corresponding todoCount in the response
//             var categoryWithCount = (data['categorywithcount'] as List)
//                 .firstWhere((item) => item['categories'] == category,
//                     orElse: () => null);

//             if (categoryWithCount != null) {
//               todoCount = categoryWithCount['todoCount'];
//             }

//             return CategoryWithTodoCount(name: category, todoCount: todoCount);
//           }).toList();

//           if (_isMounted) {
//             setState(() {
//               categories = updatedCategories;
//             });
//           }
//         } else {
//           print('No categories found for this user');
//         }
//       } else {
//         print(
//             'Failed to fetch categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error while fetching categories: $e');
//     } finally {
//       if (_isMounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _refreshCategories() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _loadCategories();
//   }

//   Future<void> addCategoryToDatabase(String category) async {
//     final prefs = await SharedPreferences.getInstance();
//     final username = prefs.getString('username') ?? '';

//     final response = await http.post(
//       Uri.parse('http://$serverIp:5000/add_category'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'category': category,
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Category sdfdggagrsa added to the database');
//       _loadCategories();
//     } else {
//       print('Failed to add category to the database');
//     }
//   }

//   Future<void> deleteCategory(String category) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://$serverIp:5000/delete_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'category': category,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category deleted from the database');
//         _loadCategories();
//       } else {
//         print('Failed to delete category from the database');
//       }
//     } catch (e) {
//       print('Error while deleting category: $e');
//     }
//   }

//   Future<void> editCategoryInDatabase(
//       String oldCategory, String newCategory) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.put(
//         Uri.parse('http://$serverIp:5000/edit_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'oldCategory': oldCategory,
//           'newCategory': newCategory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category edited in the database');
//         _loadCategories();
//       } else {
//         print('Failed to edit category in the database');
//       }
//     } catch (e) {
//       print('Error while editing category: $e');
//     }
//   }

//   Future<void> showAddCategoryDialog(BuildContext context) async {
//     TextEditingController categoryController = TextEditingController();

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add New Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: const InputDecoration(hintText: 'Enter category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 addCategoryToDatabase(categoryController.text);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showEditCategoryDialog(
//       BuildContext context, String category) async {
//     TextEditingController categoryController =
//         TextEditingController(text: category);

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Edit Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration:
//                 const InputDecoration(hintText: 'Enter new category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 String newCategory = categoryController.text;
//                 editCategoryInDatabase(category, newCategory);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Edit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showDeleteConfirmationDialog(
//       BuildContext context, String category) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Delete Category'),
//           content: const Text('Are you sure you want to delete this category?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 deleteCategory(category);
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Categories'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.add),
//             onPressed: () => _showAddCategoryBottomSheet(context),
//           ),
//         ],
//       ),
//       body: _buildCategoryList(),
//     );
//   }

//   Widget _buildCategoryList() {
//     return RefreshIndicator(
//       onRefresh: _refreshCategories,
//       child: isLoading
//           ? _buildShimmer()
//           : categories.isEmpty
//               ? _buildNoCategories()
//               : Container(
//                   padding: const EdgeInsets.all(10),
//                   child: GridView.builder(
//                     gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                     ),
//                     itemCount: categories.length,
//                     itemBuilder: (context, index) {
//                       return CategoryItem(
//                         category: categories[index].name,
//                         todoCount: categories[index].todoCount,
//                         onLongPress: () =>
//                             _showBottomSheet(context, categories[index].name),
//                         onTap: () =>
//                             _navigateToTodoList(categories[index].name),
//                       );
//                     },
//                   ),
//                 ),
//     );
//   }

//   void _showBottomSheet(BuildContext context, String category) {
//     showModalBottomSheet(
//       context: context,
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.edit),
//               title: const Text('Edit Category'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showEditCategoryDialog(context, category);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete),
//               title: const Text('Delete Category'),
//               onTap: () {
//                 Navigator.pop(context);
//                 showDeleteConfirmationDialog(context, category);
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildShimmer() {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       child: GridView.builder(
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: 8,
//         itemBuilder: (context, index) {
//           return const CategoryItemShimmer();
//         },
//       ),
//     );
//   }

//   Widget _buildNoCategories() {
//     return const Center(
//       child: Text('No categories added.'),
//     );
//   }

//   void _navigateToTodoList(String category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TodoListScreen(
//           category: category,
//           serverIp: serverIp,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pub/screens/addTodoPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/GlobalSnackbar.dart';
import '../main.dart';
import '../models/category.dart';
import '../models/todo.dart';
import '../utils/utils.dart';

class CategoriesPage extends StatefulWidget {
  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<CategoryData> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response =
          await http.get(Uri.parse('http://$serverIp:5000/categories/$userId'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final category = Category.fromJson(data);
        if (category.success ?? false) {
          setState(() {
            _categories = category.categoryData ?? [];
          });
        } else {
          if (mounted) {
            GlobalSnackbar.show(
                context, category.message ?? 'Failed to fetch categories');
          }
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(context, 'Failed to fetch categories');
        }
      }
    } catch (e) {
      print('Error: $e');
      if (e is SocketException) {
        if (mounted) {
          GlobalSnackbar.show(context,
              'Connection error: Please check your internet connection.');
        }
      } else {
        if (mounted) {
          GlobalSnackbar.show(
              context, 'An error occurred while fetching categories');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TodoListPage(category: category),
                ),
              );
            },
            child: ListTile(
              title: Text(category.categoryName ?? ''),
              subtitle: Text('Todo Count: ${category.todoCount ?? 0}'),
              leading: Container(
                width: 24,
                height: 24,
                color: _parseColor(category.categoryColor),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return Color(int.parse('0xFF$colorHex'));
    }
    return Colors.grey;
  }
}

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
