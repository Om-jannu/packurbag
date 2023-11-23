import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todos = [
    {
      "text": "sonalis birthday",
      "date": "2023-12-24T06:59:17.142Z",
      "category": "premade-Birthday",
    },
    {
      "text": "sonalis birthday",
      "date": "2023-11-24T06:59:17.142Z",
      "category": "premade-Birthday",
    },
    {
      "text": "sonalis birthday",
      "date": "2023-10-24T06:59:17.142Z",
      "category": "premade-Birthday",
    },
    {
      "text": "sonalis birthday",
      "date": "2023-11-24T06:59:17.142Z",
      "category": "premade-exercise",
    },
    {
      "text": "sonalis birthday",
      "date": "2023-10-24T06:59:17.142Z",
      "category": "premade-exercise",
    },
    {
      "text": "some fate",
      "date": "2023-11-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate",
      "date": "2023-10-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate more",
      "date": "2023-10-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate more",
      "date": "2023-10-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate more",
      "date": "2023-10-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate more",
      "date": "2023-10-25T00:00:00.000",
      "category": "some",
    },
    {
      "text": "some fate",
      "date": "2023-11-25T00:00:00.000",
      "category": "shopping",
    },
    {
      "text": "some fate",
      "date": "2023-10-25T00:00:00.000",
      "category": "shopping",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DailyTodosScreen(todos: todos),
              ),
            );
          },
          child: Text('View Daily Todos'),
        ),
      ),
    );
  }
}

class DailyTodosScreen extends StatelessWidget {
  final List<Map<String, dynamic>> todos;

  DailyTodosScreen({required this.todos});

  @override
  Widget build(BuildContext context) {
    // Group todos by date and category
    Map<String, Map<String, List<Map<String, dynamic>>>> groupedTodos = {};

    for (Map<String, dynamic> todo in todos) {
      DateTime date = DateTime.parse(todo['date']);
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      String category = todo['category'];

      if (!groupedTodos.containsKey(formattedDate)) {
        groupedTodos[formattedDate] = {};
      }

      if (!groupedTodos[formattedDate]!.containsKey(category)) {
        groupedTodos[formattedDate]![category] = [];
      }

      groupedTodos[formattedDate]![category]!.add(todo);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Todos'),
      ),
      body: ListView.builder(
        itemCount: groupedTodos.length,
        itemBuilder: (context, index) {
          String date = groupedTodos.keys.elementAt(index);
          Map<String, List<Map<String, dynamic>>> categoryTodos =
              groupedTodos[date]!;

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryTodos.entries
                        .map(
                          (entry) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category: ${entry.key}',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Column(
                                children: entry.value
                                    .map(
                                      (todo) => Text(
                                        todo['text'],
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
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
}
