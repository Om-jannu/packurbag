import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GlobalAddTodoScreen extends StatefulWidget {
  const GlobalAddTodoScreen({Key? key}) : super(key: key);

  @override
  State<GlobalAddTodoScreen> createState() => _GlobalAddTodoScreenState();
}

class _GlobalAddTodoScreenState extends State<GlobalAddTodoScreen> {
  late TextEditingController todoController;
  late TextEditingController categoryController;
  String selectedCategory = '';
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
    categoryController = TextEditingController();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('username') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/get_categories'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': currentUser,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['categories'] is List) {
          setState(() {
            categories = List<String>.from(data['categories']);
          });
        } else {
          print('No categories found for this user');
        }
      } else {
        print('Failed to fetch categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching categories: $e');
    }
  }

  Future<void> saveTodoToDatabase(String todo, String category) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('username') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/add_todo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': currentUser,
          'todo': todo,
          'category': category,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('Todo saved successfully');
        } else {
          print('Failed to save todo: ${data['message']}');
        }
      } else {
        print('Failed to save todo. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while saving todo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Todo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: todoController,
              decoration: InputDecoration(
                hintText: 'Enter your todo',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Category:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8.0,
              children: categories.map((category) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: Chip(
                    label: Text(category),
                    backgroundColor: selectedCategory == category
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (validateInputs()) {
                  saveTodo();
                }
              },
              child: Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }

  bool validateInputs() {
    if (todoController.text.isEmpty || selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return false;
    }
    return true;
  }

  void saveTodo() {
    String todo = todoController.text;
    String category = selectedCategory;

    if (!categories.contains(category)) {
      setState(() {
        categories.add(category);
      });
    }

    saveTodoToDatabase(todo, category);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    todoController.dispose();
    categoryController.dispose();
    super.dispose();
  }
}
