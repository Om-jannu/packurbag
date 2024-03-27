import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class Event {
  final String text;
  final DateTime date;
  final bool completed;
  final int priority;
  final String category;
  final String categoryColor;
  final DateTime dateOfCreation;
  final String id;

  Event({
    required this.text,
    required this.date,
    required this.completed,
    required this.priority,
    required this.category,
    required this.categoryColor,
    required this.dateOfCreation,
    required this.id,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      text: json['text'] ?? '',
      date: DateTime.parse(json['date'] ?? ''),
      completed: json['completed'] ?? false,
      priority: json['priority'] ?? 0,
      category: json['category'] ?? '',
      categoryColor: json['categoryColor'] ?? '',
      dateOfCreation: DateTime.parse(json['dateOfCreation'] ?? ''),
      id: json['_id'] ?? '',
    );
  }

  @override
  String toString() => text;
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

Future<List<Event>> fetchTodos(String userId, BuildContext context) async {
  try {
    final response =
        await http.get(Uri.parse('http://$serverIp:5000/todos/$userId'));

    if (response.statusCode == 200) {
      final todosData = jsonDecode(response.body);
      if (todosData['success']) {
        final List<dynamic> todos = todosData['data'];
        return todos.map<Event>((todo) => Event.fromJson(todo)).toList();
      } else {
        throw Exception('Failed to load todos: ${todosData['message']}');
      }
    } else {
      throw Exception('Failed to load todos: ${response.reasonPhrase}');
    }
  } catch (e) {
    final errorMessage = e is SocketException
        ? 'Connection error: Please check your internet connection.'
        : 'An error occurred while fetching todos';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
    throw Exception('Failed to load todos: $e');
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, this.serverIp}) : super(key: key);

  final String? serverIp;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Event> _allEvents = [];
  List<Event> _events = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final todos = await fetchTodos(userId, context);

      // Get todos for the selected or current date
      final DateTime selectedDate = _selectedDay ?? DateTime.now();
      final selectedTodos = todos
          .where((event) =>
              event.date.year == selectedDate.year &&
              event.date.month == selectedDate.month &&
              event.date.day == selectedDate.day)
          .toList();

      setState(() {
        _events = selectedTodos;
        _allEvents = todos; // Populate all events
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) => isSameDay(event.date, day)).toList();
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);
    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
        _events = _getEventsForDay(selectedDay);
      });
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      setState(() {
        _events = _getEventsForRange(start, end);
      });
    } else if (start != null) {
      setState(() {
        _events = _getEventsForDay(start);
      });
    } else if (end != null) {
      setState(() {
        _events = _getEventsForDay(end);
      });
    }
  }

  bool _groupByCategory = true;
  @override
  Widget build(BuildContext context) {
    int pendingTodosCount = _events.where((event) => !event.completed).length;

    // Group todos by category
    Map<String, List<Event>> todosByCategory = {};
    for (Event event in _events) {
      if (!todosByCategory.containsKey(event.category)) {
        todosByCategory[event.category] = [];
      }
      todosByCategory[event.category]!.add(event);
    }

    // Group todos by priority
    Map<String, List<Event>> todosByPriority = {};
    for (Event event in _events) {
      String priorityKey = event.priority.toString();
      if (!todosByPriority.containsKey(priorityKey)) {
        todosByPriority[priorityKey] = [];
      }
      todosByPriority[priorityKey]!.add(event);
    }

    // Determine which grouping option is currently selected
    Map<String, List<Event>> selectedGroup;
    String selectedGroupTitle;
    if (_groupByCategory) {
      selectedGroup = todosByCategory;
      selectedGroupTitle = 'Category';
    } else {
      selectedGroup = todosByPriority;
      selectedGroupTitle = 'Priority';
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("PackUrBag"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              // Handle calendar button tap
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                if (value == 'category') {
                  _groupByCategory = true;
                } else {
                  _groupByCategory = false;
                }
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'category',
                child: Text('Group by Category'),
              ),
              const PopupMenuItem<String>(
                value: 'priority',
                child: Text('Group by Priority'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 8.0),
          Text(
            'Pending Todos: $pendingTodosCount',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: _events.isEmpty
                ? const Center(
                    child: Text('No todos added'),
                  )
                : ListView.builder(
                    itemCount: selectedGroup.length,
                    itemBuilder: (context, index) {
                      dynamic groupKey = selectedGroup.keys.elementAt(index);
                      List<Event> todosInGroup = selectedGroup[groupKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Text(
                              '$selectedGroupTitle: $groupKey',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: todosInGroup.length,
                            itemBuilder: (context, index) {
                              Event todo = todosInGroup[index];
                              return ListTile(
                                title: Text(todo.text),
                                leading: todo.completed
                                    ? const Icon(Icons.check_circle,
                                        color: Colors.green)
                                    : const Icon(Icons.radio_button_unchecked),
                                onTap: () {
                                  // Handle todo tap
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
