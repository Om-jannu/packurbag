import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class GlobalAddTodoScreen extends StatefulWidget {
  const GlobalAddTodoScreen({Key? key, var serverIp}) : super(key: key);

  @override
  State<GlobalAddTodoScreen> createState() => _GlobalAddTodoScreenState();
}

class _GlobalAddTodoScreenState extends State<GlobalAddTodoScreen> {
  late TextEditingController todoController;
  String selectedCategory = '';
  List<String> categories = [];
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    todoController = TextEditingController();
    selectedDate = DateTime.now();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('username') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:5000/get_categories'),
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

  Future<void> saveTodoToDatabase(String todo, String category, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = prefs.getString('username') ?? '';

    try {
      final response = await http.post(
        Uri.parse('http://$serverIp:5000/add_todo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': currentUser,
          'todo': todo,
          'category': category,
          'date': date.toIso8601String(),
          'completed': false,
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
            Text(
              'Date:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                      text: DateFormat('MMMM d, y').format(selectedDate),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Select Date',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text('Pick Date'),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (validateInputs()) {
                  saveTodo();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Add Todo',
                style: TextStyle(fontSize: 16),
              ),
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

    saveTodoToDatabase(todo, category, selectedDate);
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    todoController.dispose();
    super.dispose();
  }
}
