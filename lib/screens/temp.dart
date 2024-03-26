import 'package:flutter/material.dart';

class TaskList extends StatefulWidget {
  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  List<Map<String, dynamic>> tasks = [
    {
      'title': 'Morning workout',
      'time': '7:00 AM',
      'category': 'Home',
      'categoryColor': Colors.purple,
    },
    {
      'title': 'Make a presentation about',
      'time': '11:00 AM',
      'category': 'Study',
      'categoryColor': Colors.orange,
    },
    {
      'title': 'Organize last week\'s sales',
      'time': '1:00 PM',
      'category': 'Work',
      'categoryColor': Colors.blue,
    },
    {
      'title': 'Meeting with Amy',
      'time': '3:00 PM',
      'category': 'Meeting',
      'categoryColor': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: task['categoryColor'],
              child: Icon(
                getCategoryIcon(task['category']),
                color: Colors.white,
              ),
            ),
            title: Text(task['title']),
            subtitle: Text(task['time']),
            trailing: Text(
              task['category'],
              style: TextStyle(
                color: task['categoryColor'],
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add task for today
        },
        child: Icon(Icons.add),
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Home':
        return Icons.home;
      case 'Study':
        return Icons.book;
      case 'Work':
        return Icons.work;
      case 'Meeting':
        return Icons.meeting_room;
      default:
        return Icons.event;
    }
  }
}
