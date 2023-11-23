import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  const CategoriesScreen({Key? key, var serverIp}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<CategoryWithTodoCount> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    addCategoryToDatabase("premade-Birthday");
    addCategoryToDatabase("premade-Shopping");
    addCategoryToDatabase("premade-Exercise");
    addCategoryToDatabase("premade-Events");
    addCategoryToDatabase("premade-Meetings");
    addCategoryToDatabase("premade-Exams");
    addCategoryToDatabase("premade-Reading");
    addCategoryToDatabase("premade-Savings");
    addCategoryToDatabase("premade-Bills");
    addCategoryToDatabase("premade-Trips");
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.post(
        Uri.parse('http://$serverIp:5000/get_categories'),
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
    await Future.delayed(const Duration(seconds: 1));
    await _loadCategories();
  }

  Future<void> addCategoryToDatabase(String category) async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';

    final response = await http.post(
      Uri.parse('http://$serverIp:5000/add_category'),
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
        Uri.parse('http://$serverIp:5000/delete_category'),
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

  Future<void> editCategoryInDatabase(
      String oldCategory, String newCategory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.put(
        Uri.parse('http://$serverIp:5000/edit_category'),
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
          title: const Text('Add New Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(hintText: 'Enter category name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                addCategoryToDatabase(categoryController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditCategoryDialog(
      BuildContext context, String category) async {
    TextEditingController categoryController =
        TextEditingController(text: category);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Category'),
          content: TextField(
            controller: categoryController,
            decoration: const InputDecoration(hintText: 'Enter new category name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String newCategory = categoryController.text;
                editCategoryInDatabase(category, newCategory);
                Navigator.of(context).pop();
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, String category) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Category'),
          content: const Text('Are you sure you want to delete this category?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                 deleteCategory(category);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
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
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: const Text('Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
              : Container(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return CategoryItem(
                        category: categories[index].name,
                        todoCount: categories[index].todoCount,
                        onLongPress: () =>
                            _showBottomSheet(context, categories[index].name),
                        onTap: () =>
                            _navigateToTodoList(categories[index].name),
                      );
                    },
                  ),
                ),
    );
  }

  void _showBottomSheet(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Category'),
              onTap: () {
                Navigator.pop(context);
                showEditCategoryDialog(context, category);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Category'),
              onTap: () {
                Navigator.pop(context);
                showDeleteConfirmationDialog(context, category);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return Container(
      padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return const CategoryItemShimmer();
          },
        ),
      );
  }

  Widget _buildNoCategories() {
    return const Center(
      child: Text('No categories added.'),
    );
  }

  void _navigateToTodoList(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoListScreen(
          category: category,
          serverIp: serverIp,
        ),
      ),
    );
  }
}
