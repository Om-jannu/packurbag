import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pub/extensions.dart';
import 'package:pub/main.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/GlobalSnackbar.dart';
import '../models/event.dart';
import '../pages/sosScreen.dart';
import '../utils.dart';

Future<List<Event>> fetchTodos(String userId, BuildContext context) async {
  try {
    final response = await http.get(Uri.parse('$serverIp/todos/$userId'));

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
  const HomeScreen({Key? key}) : super(key: key);

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
  bool _showIncompleteTasks = false;
  bool _groupByCategory = true;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription;
  bool _isShaking = false;
  bool _isSosPageOpen = false;
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTodos();
    _startListeningToAccelerometer();
  }

  @override
  void dispose() {
    _stopListeningToAccelerometer();
    super.dispose();
  }

  void _startListeningToAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      final double accelerationSquared =
          event.x * event.x + event.y * event.y + event.z * event.z;
      final double acceleration = sqrt(accelerationSquared);

      if (acceleration > 50 && !_isSosPageOpen) {
        // Check if SOS page is not already open
        setState(() {
          _isShaking = true;
        });

        // Set the flag to true to prevent opening SOS page multiple times
        _isSosPageOpen = true;

        // Navigate to SOS screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SosScreen()),
        ).then((_) {
          // Reset the flag when SOS page is closed
          _isSosPageOpen = false;
        });

        setState(() {
          _isShaking = false;
        });
      }
    });
  }

  void _stopListeningToAccelerometer() {
    _accelerometerSubscription.cancel();
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

  Future<void> updateTodoCompletionStatus(
      Event todo, bool completedStatus) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';
      final response = await http.put(
        Uri.parse('$serverIp/todos/$userId/${todo.id}/completedStatus'),
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
    if (_groupByCategory) {
      selectedGroup = todosByCategory;
    } else {
      selectedGroup = todosByPriority;
    }

    Widget buildCountTile(IconData icon, String title, int count) {
      return Card(
        child: ListTile(
          leading: Icon(
            icon,
            size: 20,
          ),
          title: Text(title),
          subtitle: Text('$count tasks'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icon_packurbag.png', // Replace with your custom logo path
              width: 50,
              height: 50,
            ),
            const Text("packurbag")
          ],
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
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
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: const TextStyle().copyWith(color: Colors.red),
              holidayTextStyle: const TextStyle().copyWith(color: Colors.blue),
              selectedTextStyle:
                  const TextStyle().copyWith(color: Colors.white),
              todayTextStyle: const TextStyle().copyWith(color: Colors.green),
              markersAlignment: Alignment.bottomCenter,
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.green,
                  width: 2.0,
                ),
              ),
              selectedDecoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
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
              buildCountTile(
                  FontAwesomeIcons.hourglassHalf, 'Pending', pendingTodosCount),
              buildCountTile(
                  FontAwesomeIcons.calendarXmark, 'Overdue', overdueTodosCount),
              buildCountTile(
                  Icons.pending_actions, 'Upcoming', upcomingTodosCount),
              buildCountTile(FontAwesomeIcons.circleCheck, 'Completed',
                  completedTodosCount),
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
                Row(
                  children: [
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
                    Switch(
                      value: _showIncompleteTasks,
                      onChanged: (value) {
                        setState(() {
                          _showIncompleteTasks = value;
                        });
                      },
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
                // Filter completed tasks if _showIncompleteTasks is true
                if (_showIncompleteTasks) {
                  todosInGroup =
                      todosInGroup.where((todo) => !todo.completed).toList();
                }

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
        return Colors.blueGrey;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
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
          color: Colors.blueGrey,
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
          color: Colors.yellow,
        );
      case 3:
        return const FaIcon(
          size: 15,
          FontAwesomeIcons.anglesUp,
          color: Colors.orange,
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
