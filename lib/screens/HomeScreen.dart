import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pub/extensions.dart';
import 'package:pub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/GlobalSnackbar.dart';
import '../models/event.dart';
import '../utils/utils.dart';

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
  CalendarFormat _calendarFormat = CalendarFormat.week;
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

    // Get today's date without the time portion
    DateTime today = DateTime.now().toLocal();
    DateTime todayWithoutTime = DateTime(today.year, today.month, today.day);

    // Count upcoming todos
    int upcomingTodosCount = _allEvents
        .where(
            (event) => !event.completed && event.date.toLocal().isAfter(today))
        .length;

    // Count overdue todos
    int overdueTodosCount = _allEvents
        .where((event) =>
            !event.completed && event.date.toLocal().isBefore(todayWithoutTime))
        .length;
    int completedTodosCount = _events.where((event) => event.completed).length;
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
    Future<void> updateTodoCompletionStatus(
        Event todo, bool completedStatus) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId') ?? '';
        final response = await http.put(
          Uri.parse(
              'http://$serverIp:5000/todos/$userId/${todo.id}/completedStatus'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'completed': completedStatus,
          }),
        );

        if (response.statusCode == 200) {
          setState(() {
            // Update the todo in the list
            todo.completed = completedStatus;
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

    Widget buildCountTile(IconData icon, String title, int count) {
      return Card(
        child: ListTile(
          leading: Icon(icon,size: 20,),
          title: Text(title),
          subtitle: Text('$count tasks'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("PackUrBag"),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.calendar_month),
        //     onPressed: () {
        //       // Handle calendar button tap
        //     },
        //   ),
        // ],
      ),
      body: Column(
        children: [
          TableCalendar<Event>(
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
            ),
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
          GridView.count(
            shrinkWrap: true,
            childAspectRatio: (1 / .4),
            crossAxisCount: 2, // You can adjust the number of columns here
            children: [
              buildCountTile(FontAwesomeIcons.hourglassHalf, 'Pending', pendingTodosCount),
              buildCountTile(
                  FontAwesomeIcons.calendarXmark, 'Overdue', overdueTodosCount),
              buildCountTile(
                  Icons.pending_actions, 'Upcoming', upcomingTodosCount),
              buildCountTile(Icons.done, 'Completed', completedTodosCount),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormat('E, MMM d').format(_selectedDay!)
                      : 'Today',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                PopupMenuButton<String>(
                  icon: const FaIcon(FontAwesomeIcons.filter),
                  iconSize: 16,
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: selectedGroup.length,
              itemBuilder: (context, index) {
                dynamic groupKey = selectedGroup.keys.elementAt(index);
                List<Event> todosInGroup = selectedGroup[groupKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: todosInGroup.length,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemBuilder: (context, index) {
                        Event todo = todosInGroup[index];
                        return ListTile(
                          horizontalTitleGap: 5,
                          leading: Transform.scale(
                            scale: 1.2,
                            child: Checkbox(
                              side: BorderSide(
                                  color: _parseColor(todo.categoryColor)),
                              activeColor: Colors.transparent,
                              checkColor: _parseColor(todo.categoryColor),
                              shape: const CircleBorder(),
                              value: todo.completed,
                              onChanged: (bool? value) async {
                                updateTodoCompletionStatus(todo, value!);
                                setState(() {
                                  todo.completed = value;
                                });
                              },
                            ),
                          ),
                          title: Text(
                            todo.text,
                            style: TextStyle(
                              color: todo.completed
                                  ? Colors.grey[600]
                                  : Colors.white,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: _parseColor(todo.categoryColor)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3, horizontal: 8),
                                child: Text(
                                  todo.category.capitalize(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                children: [
                                  _getPriorityIcon(todo.priority),
                                  const SizedBox(width: 4),
                                  Text(
                                    priorityLabels[todo.priority] ?? 'Unknown',
                                    style: TextStyle(
                                      color:
                                          _getPriorityIconColor(todo.priority),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Color _getPriorityIconColor(int priority) {
    switch (priority) {
      case 0:
        return Colors.grey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.deepOrange;
      case 3:
        return Colors.redAccent;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  FaIcon _getPriorityIcon(int priority) {
    switch (priority) {
      case 0:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.spinner,
          color: Colors.grey,
        );
      case 1:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesDown,
          color: Colors.blue,
        );
      case 2:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.water,
          color: Colors.deepOrange,
        );
      case 3:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesUp,
          color: Colors.redAccent,
        );
      case 4:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.triangleExclamation,
          color: Colors.red,
        );
      default:
        return const FaIcon(
          FontAwesomeIcons.question,
          color: Colors.grey,
        );
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex != null && colorHex.isNotEmpty) {
      return Color(int.parse('0xFF$colorHex'));
    }
    return Colors.grey;
  }
}
