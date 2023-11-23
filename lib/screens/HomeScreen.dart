import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, var serverIp}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDay;
  List<Map<String, dynamic>> todos = [];
  List<String> categories = [];
  String? _selectedCategory;
  Map<DateTime, List<dynamic>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadCategories();
    _loadInitialTodos();
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

        if (data['success'] == true && data['categories'] != null) {
          setState(() {
            categories = List<String>.from(data['categories']);
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
    }
  }

  Future<void> _loadInitialTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final response = await http.post(
        Uri.parse('http://$serverIp:5000/get_todos_by_date'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'selectedDate': _selectedDay.toIso8601String(),
          'category': _selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['todos'] != null && data['todos'] is List) {
          setState(() {
            todos = List<Map<String, dynamic>>.from(data['todos']);
          });

          // Update events for the current month
          _updateEvents(_selectedDay);
        } else {
          print('No todos found for this user on $_selectedDay');
        }
      } else {
        print('Failed to fetch todos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching todos: $e');
    }
  }

  Future<void> _loadTodos(DateTime selectedDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final response = await http.post(
        Uri.parse('http://$serverIp:5000/get_todos_by_date'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'selectedDate': selectedDate.toIso8601String(),
          'category': _selectedCategory,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['todos'] != null && data['todos'] is List) {
          setState(() {
            todos = List<Map<String, dynamic>>.from(data['todos']);
          });

          // Update events for the selected date
          _updateEvents(selectedDate);
        } else {
          print('No todos found for this user on $selectedDate');
        }
      } else {
        print('Failed to fetch todos. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error while fetching todos: $e');
    }
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
    });
    _loadTodos(day);
  }

void _updateEvents(DateTime date) {
  if (date.month == _selectedDay.month) {
    setState(() {
      events = {
        ...events,
        date: todos.map((todo) => todo['text']).toList(),
      };
    });
  }
  print("smth ===============================");
  print(events);
}


  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: _getCategoryFilterChips(),
      ),
    );
  }

Future<void> _loadAllTodos() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username') ?? '';
    final response = await http.post(
      Uri.parse('http://$serverIp:5000/get_todos_by_date'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['todos'] != null && data['todos'] is List) {
        setState(() {
          todos = List<Map<String, dynamic>>.from(data['todos']);
        });

        // Update events for the current month
        _updateEvents(_selectedDay);
      } else {
        print('No todos found for this user');
      }
    } else {
      print('Failed to fetch todos. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error while fetching todos: $e');
  }
}

  List<Widget> _getCategoryFilterChips() {
    return categories.map((category) {
      return FilterChip(
        label: Text(category),
        selected: _selectedCategory == category,
        onSelected: (isSelected) {
          setState(() {
            _selectedCategory = isSelected ? category : null;
          });
          _loadTodos(_selectedDay);
        },
      );
    }).toList();
  }

  Widget _buildCalendar() {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      margin: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Color.fromRGBO(67, 36, 111,1),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: TableCalendar(
        focusedDay: _selectedDay,
        firstDay: DateTime(2001, 1, 1),
        lastDay: DateTime(2030, 12, 31),
        rowHeight: 40,
        calendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.all,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
        onDaySelected: _onDaySelected,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        eventLoader: (day) => events[day] ?? [],
        calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          markerDecoration: BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    return Expanded(
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index]['text']),
            subtitle: Text('Category: ${todos[index]['category']}'),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildFilterChips(),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _loadAllTodos();
            },
          ),
        ],
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildCalendar(),
          _buildTodoList(),
        ],
      ),
    );
  }
}
