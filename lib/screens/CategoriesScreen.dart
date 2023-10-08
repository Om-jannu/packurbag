// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// import '../components/CategoryItem.dart';
// import '../components/CategoryItemShimmer.dart';
// import 'TodoListScreen.dart';

// class CategoriesScreen extends StatefulWidget {
//   const CategoriesScreen({Key? key}) : super(key: key);

//   @override
//   State<CategoriesScreen> createState() => _CategoriesScreenState();
// }

// class _CategoriesScreenState extends State<CategoriesScreen> {
//   List<String> categories = [];
//   bool isLoading = true;
//   late DateTime _selectedDay;

//   @override
//   void initState() {
//     super.initState();
//     _selectedDay = DateTime.now();
//     _loadCategories(_selectedDay);
//   }

//   Future<void> _loadCategories(DateTime selectedDate) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://192.168.0.115:5000/get_categories'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'selectedDate': selectedDate.toIso8601String(),
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data['categories'] != null && data['categories'] is List) {
//           setState(() {
//             categories = List<String>.from(data['categories']);
//           });
//         } else {
//           print('No categories found for this user on $selectedDate');
//         }
//       } else {
//         print(
//             'Failed to fetch categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error while fetching categories: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _refreshCategories() async {
//     await Future.delayed(Duration(seconds: 1));
//     await _loadCategories(_selectedDay);
//   }

//   Future<void> addCategoryToDatabase(
//       String category, DateTime selectedDate) async {
//     final prefs = await SharedPreferences.getInstance();
//     final username = prefs.getString('username') ?? '';

//     final response = await http.post(
//       Uri.parse('http://192.168.0.115:5000/add_category'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'category': category,
//         'selectedDate': selectedDate.toIso8601String(),
//       }),
//     );

//     if (response.statusCode == 200) {
//       print('Category added to the database');
//       _loadCategories(selectedDate);
//     } else {
//       print('Failed to add category to the database');
//     }
//   }

//   Future<void> deleteCategory(String category) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://192.168.0.115:5000/delete_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'category': category,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category deleted from the database');
//         _loadCategories(_selectedDay);
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
//         Uri.parse('http://192.168.0.115:5000/edit_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'oldCategory': oldCategory,
//           'newCategory': newCategory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('Category edited in the database');
//         _loadCategories(_selectedDay);
//       } else {
//         print('Failed to edit category in the database');
//       }
//     } catch (e) {
//       print('Error while editing category: $e');
//     }
//   }

//   Future<void> showAddCategoryDialog(
//       BuildContext context, DateTime selectedDate) async {
//     TextEditingController categoryController = TextEditingController();

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add New Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: InputDecoration(hintText: 'Enter category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 addCategoryToDatabase(categoryController.text, selectedDate);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Add'),
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
//           title: Text('Edit Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: InputDecoration(hintText: 'Enter new category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 String newCategory = categoryController.text;
//                 await editCategoryInDatabase(category, newCategory);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Edit'),
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
//           title: Text('Delete Category'),
//           content: Text('Are you sure you want to delete this category?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 await deleteCategory(category);
//                 Navigator.of(context).pop();
//               },
//               child: Text('Delete'),
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
//         title: Text('Categories'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.add),
//             onPressed: () {
//               showAddCategoryDialog(context, _selectedDay);
//             },
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
//               : Column(
//                   children: [
//                     Expanded(
//                       child: GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 8.0,
//                           mainAxisSpacing: 8.0,
//                         ),
//                         itemCount: categories.length,
//                         itemBuilder: (context, index) {
//                           return CategoryItem(
//                             category: categories[index],
//                             onDelete: () => showDeleteConfirmationDialog(
//                                 context, categories[index]),
//                             onEdit: () => showEditCategoryDialog(
//                                 context, categories[index]),
//                             onTap: () => _navigateToTodoList(categories[index]),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }

//   Widget _buildBody() {
//     return Column(
//       children: [
//         Expanded(
//           child: _buildCategoryList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8.0,
//           mainAxisSpacing: 8.0,
//         ),
//         itemCount: 8,
//         itemBuilder: (context, index) {
//           return CategoryItemShimmer();
//         },
//       ),
//     );
//   }

//   Widget _buildNoCategories() {
//     return Center(
//       child: Text('No categories added.'),
//     );
//   }

//   void _navigateToTodoList(String category) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TodoListScreen(
//           category: category,
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../components/CategoryItem.dart';
import '../components/CategoryItemShimmer.dart';
import 'TodoListScreen.dart';

class CategoryWithTodoCount {
  final String name;
  final int todoCount;

  CategoryWithTodoCount({
    required this.name,
    required this.todoCount,
  });
}

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryWithTodoCount> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/get_categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['categories'] != null && data['categories'] is List) {
          List<CategoryWithTodoCount> updatedCategories =
              List<String>.from(data['categories']).map((category) {
            int todoCount = 0;

            // Find the corresponding todoCount in the response
            var categoryWithCount = (data['categorywithcount'] as List)
                .firstWhere((item) => item['categories'] == category,
                    orElse: () => null);

            if (categoryWithCount != null) {
              todoCount = categoryWithCount['todoCount'];
            }

            return CategoryWithTodoCount(name: category, todoCount: todoCount);
          }).toList();

          setState(() {
            categories = updatedCategories;
          });
        } else {
          print('No categories found for this user');
        }
      } else {
        print(
            'Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching categories: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _refreshCategories() async {
    await Future.delayed(Duration(seconds: 1));
    await _loadCategories();
  }

  Future<void> addCategoryToDatabase(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.post(
      Uri.parse('http://192.168.0.115:5000/add_category'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'category': category,
      }),
    );

    if (response.statusCode == 200) {
      print('Category added to the database');
      _loadCategories();
    } else {
      print('Failed to add category to the database');
    }
  }

  Future<void> deleteCategory(String category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/delete_category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        print('Category deleted from the database');
        _loadCategories();
      } else {
        print('Failed to delete category from the database');
      }
    } catch (e) {
      print('Error while deleting category: $e');
    }
  }

  Future<void> editCategoryInDatabase(String oldCategory, String newCategory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.put(
        Uri.parse('http://192.168.0.115:5000/edit_category'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'oldCategory': oldCategory,
          'newCategory': newCategory,
        }),
      );

      if (response.statusCode == 200) {
        print('Category edited in the database');
        _loadCategories();
      } else {
        print('Failed to edit category in the database');
      }
    } catch (e) {
      print('Error while editing category: $e');
    }
  }

  Future<void> showAddCategoryDialog(BuildContext context) async {
    TextEditingController categoryController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Enter category name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addCategoryToDatabase(categoryController.text);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditCategoryDialog(BuildContext context, String category) async {
    TextEditingController categoryController =
        TextEditingController(text: category);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            controller: categoryController,
            decoration: InputDecoration(hintText: 'Enter new category name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newCategory = categoryController.text;
                await editCategoryInDatabase(category, newCategory);
                Navigator.of(context).pop();
              },
              child: Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(BuildContext context, String category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteCategory(category);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAddCategoryDialog(context);
            },
          ),
        ],
      ),
      body: _buildCategoryList(),
    );
  }

  Widget _buildCategoryList() {
    return RefreshIndicator(
      onRefresh: _refreshCategories,
      child: isLoading
          ? _buildShimmer()
          : categories.isEmpty
              ? _buildNoCategories()
              : Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryItem(
                            category: categories[index].name,
                            todoCount: categories[index].todoCount,
                            onDelete: () => showDeleteConfirmationDialog(
                                context, categories[index].name),
                            onEdit: () => showEditCategoryDialog(
                                context, categories[index].name),
                            onTap: () =>
                                _navigateToTodoList(categories[index].name),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _buildCategoryList(),
        ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return CategoryItemShimmer();
        },
      ),
    );
  }

  Widget _buildNoCategories() {
    return Center(
      child: Text('No categories added.'),
    );
  }

  void _navigateToTodoList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoListScreen(
          category: category,
        ),
      ),
    );
  }
}
