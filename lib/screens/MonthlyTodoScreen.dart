import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DailyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Center(
        child: FutureBuilder(
          future: fetchTodos(), // Fetch todos from the API
          builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return DailyTodosScreen(todos: snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchTodos() async {
    final apiUrl = 'http://192.168.0.120:5000/get_todos_by_date';
    final Map<String, dynamic> requestData = {
      'username': 'om',
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['success']) {
        final List<dynamic> todosData = data['todos'];
        return List<Map<String, dynamic>>.from(todosData);
      } else {
        throw Exception('API returned an error: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load todos');
    }
  }
}

class DailyTodosScreen extends StatefulWidget {
  final List<Map<String, dynamic>> todos;

  DailyTodosScreen({required this.todos});

  @override
  _DailyTodosScreenState createState() => _DailyTodosScreenState();
}

class _DailyTodosScreenState extends State<DailyTodosScreen> {
  @override
  Widget build(BuildContext context) {
    // Group todos by date and category
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedTodos = {};

    for (Map<String, dynamic> todo in widget.todos) {
      String date = todo['date'];
      String category = todo['category'];

      if (!groupedTodos.containsKey(date)) {
        groupedTodos[date] = {};
      }

      if (!groupedTodos[date]!.containsKey(category)) {
        groupedTodos[date]![category] = [];
      }

      groupedTodos[date]![category]!.add(todo);
    }

    return Scaffold(
      body: ListView.builder(
        itemCount: groupedTodos.length,
        itemBuilder: (context, index) {
          String date = groupedTodos.keys.elementAt(index);
          Map<String, List<Map<String, dynamic>>> categoryTodos =
              groupedTodos[date]!;

          // Extract date components
          DateTime dateTime = DateTime.parse(date);
          String dayOfWeek = DateFormat('EEEE').format(dateTime);
          String month = DateFormat('MMMM').format(dateTime);
          String day = DateFormat('d').format(dateTime);
          String year = DateFormat('y').format(dateTime);

          return Container(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dayOfWeek,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        month,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        day,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        year,
                        style: TextStyle(
                          fontSize: 20.0,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryTodos.entries
                        .expand(
                          (entry) => [
                            ...entry.value
                                .map(
                                  (todo) => ListTile(
                                    title: Row(
                                      children: [
                                        Checkbox(
                                          shape: CircleBorder(),
                                          side: BorderSide(color: _getCategoryColor(entry.key)),
                                          value: todo['completed'],
                                          onChanged: (bool? value) {
                                            // Handle checkbox change
                                            updateTodoCompletionStatus(todo, value!);
                                          },
                                          activeColor: Colors.grey[700], // Set color based on category
                                        ),
                                        Text(
                                          todo['text'],
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            decoration: todo['completed']
                                                ? TextDecoration.lineThrough
                                                : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            SizedBox(height: 8.0),
                          ],
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Define a function to get category color
  Color _getCategoryColor(String category) {
    switch (category) {
      case "premade-Birthday":
        return Colors.red; // Choose your color
      case "premade-exercise":
        return Colors.green; // Choose your color
      case "some":
        return Colors.blue; // Choose your color
      case "shopping":
        return Colors.orange; // Choose your color
      default:
        return Colors.grey; // Choose a default color
    }
  }

  // Function to update the completion status of a todo
  void updateTodoCompletionStatus(Map<String, dynamic> todo, bool completed) {
    // Call your API endpoint to update the completion status
    // Replace this URL with the actual API endpoint
    final apiUrl = 'https://your-api-endpoint.com/todos/${todo['id']}';
    http.put(Uri.parse(apiUrl), body: {'completed': completed.toString()});

    // Update the UI to reflect the change
    setState(() {
      todo['completed'] = completed;
    });
  }
}
