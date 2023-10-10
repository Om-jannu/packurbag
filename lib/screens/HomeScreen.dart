// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shimmer/shimmer.dart';

// import '../components/CategoryItem.dart';
// import '../components/CategoryItemShimmer.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   List<String> categories = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadCategories();
//   }

//   Future<void> _loadCategories() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://192.168.0.115:5000/get_categories'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Ensure that 'categories' key is present and not null
//         if (data['categories'] != null && data['categories'] is List) {
//           setState(() {
//             categories = List<String>.from(data['categories']);
//           });
//         } else {
//           print('No categories found for this user');
//         }
//       } else {
//         // Handle error
//         print(
//             'Failed to fetch categories. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error while fetching categories: $e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> addCategoryToDatabase(String category) async {
//     // Send a request to add the category to the database
//     final prefs = await SharedPreferences.getInstance();
//     final username = prefs.getString('username') ?? '';

//     final response = await http.post(
//       Uri.parse('http://192.168.0.115:5000/add_category'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'username': username,
//         'category': category,
//       }),
//     );

//     if (response.statusCode == 200) {
//       // Successfully added category to the database
//       print('Category added to the database');
//       _loadCategories(); // Refresh categories after adding a new one
//     } else {
//       // Handle error
//       print('Failed to add category to the database');
//     }
//   }

//   Future<void> deleteCategory(String category) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.post(
//         Uri.parse('http://192.168.0.115:5000/delete_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'category': category,
//         }),
//       );

//       if (response.statusCode == 200) {
//         // Successfully deleted category from the database
//         print('Category deleted from the database');
//         _loadCategories(); // Refresh categories after deleting one
//       } else {
//         // Handle error
//         print('Failed to delete category from the database');
//       }
//     } catch (e) {
//       print('Error while deleting category: $e');
//     }
//   }

//   Future<void> editCategoryInDatabase(
//       String oldCategory, String newCategory) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final username = prefs.getString('username') ?? '';

//       final response = await http.put(
//         Uri.parse('http://192.168.0.115:5000/edit_category'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'username': username,
//           'oldCategory': oldCategory,
//           'newCategory': newCategory,
//         }),
//       );

//       if (response.statusCode == 200) {
//         // Successfully edited category in the database
//         print('Category edited in the database');
//         _loadCategories(); // Refresh categories after editing one
//       } else {
//         // Handle error
//         print('Failed to edit category in the database');
//       }
//     } catch (e) {
//       print('Error while editing category: $e');
//     }
//   }

//   Future<void> showAddCategoryDialog(BuildContext context) async {
//     TextEditingController categoryController = TextEditingController();

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Add New Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: InputDecoration(hintText: 'Enter category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 // Add the category to the database
//                 addCategoryToDatabase(categoryController.text);
//                 // Close the dialog
//                 Navigator.of(context).pop();
//               },
//               child: Text('Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showEditCategoryDialog(
//       BuildContext context, String category) async {
//     TextEditingController categoryController =
//         TextEditingController(text: category);

//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Category'),
//           content: TextField(
//             controller: categoryController,
//             decoration: InputDecoration(hintText: 'Enter new category name'),
//           ),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Get the new category name
//                 String newCategory = categoryController.text;

//                 // Edit the category name in the database
//                 await editCategoryInDatabase(category, newCategory);

//                 // Close the dialog
//                 Navigator.of(context).pop();
//               },
//               child: Text('Edit'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showDeleteConfirmationDialog(
//       BuildContext context, String category) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Delete Category'),
//           content: Text('Are you sure you want to delete this category?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // Close the dialog
//               },
//               child: Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Delete the category from the database
//                 await deleteCategory(category);
//                 // Close the dialog
//                 Navigator.of(context).pop();
//               },
//               child: Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Categories'),
//       ),
//       body: isLoading
//           ? _buildShimmer()
//           : categories.isEmpty
//               ? _buildNoCategories()
//               : _buildCategoryList(),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => showAddCategoryDialog(context),
//         tooltip: 'Add Category',
//         child: Icon(Icons.add),
//       ),
//     );
//   }

//   Widget _buildShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 8.0,
//           mainAxisSpacing: 8.0,
//         ),
//         itemCount: 8, // You can adjust the number of shimmer items
//         itemBuilder: (context, index) {
//           return CategoryItemShimmer(); // Create a shimmer item widget
//         },
//       ),
//     );
//   }

//   Widget _buildNoCategories() {
//     return Center(
//       child: Text('No categories added.'),
//     );
//   }

//   Widget _buildCategoryList() {
//     return GridView.builder(
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 8.0,
//         mainAxisSpacing: 8.0,
//       ),
//       itemCount: categories.length,
//       itemBuilder: (context, index) {
//         return CategoryItem(
//           category: categories[index],
//           onDelete: () =>
//               showDeleteConfirmationDialog(context, categories[index]),
//           onEdit: () => showEditCategoryDialog(context, categories[index]),
//         );
//       },
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDay;
  late DateTime focusedDay;
  List<Map<String, dynamic>> todos = [];
  bool isLoading = false;
  String? _selectedCategory;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    focusedDay = DateTime.now();
    _loadCategories();
    _loadTodos(_selectedDay);

  }

  Future<void> _loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/get_categories'),
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

  Future<void> _loadTodos(DateTime selectedDate) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';
      final response = await http.post(
        Uri.parse('http://192.168.0.115:5000/get_todos_by_date'),
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

  Future<void> _refreshTodos() async {
    await Future.delayed(Duration(seconds: 1));
    await _loadTodos(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
        ),
        _buildCalendar(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${_formattedDate(_selectedDay)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        _buildFilterChips(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshTodos,
            child: isLoading
                ? _buildShimmer()
                : todos.isEmpty
                    ? _buildNoTodos()
                    : _buildTodoList(),
          ),
        ),
      ],
    );
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
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime(2022, 1, 1),
      lastDay: DateTime(2030, 12, 31),
      calendarFormat: CalendarFormat.month,
      rowHeight: 40,
      onDaySelected: (selectedDay, focusedDay) {
        print('$selectedDay');
        setState(() {
          _selectedDay = selectedDay;
        });
        _loadTodos(selectedDay);
      },
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
      onPageChanged: (focusedDay) {
        _selectedDay = focusedDay;
        _loadTodos(_selectedDay);
      },
    );
  }

  String _formattedDate(DateTime date) {
    return "${_getMonthName(date.month)} ${date.day}";
  }

  String _getMonthName(int month) {
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[600]!,
      highlightColor: Colors.grey[400]!,
      child: ListView.builder(
        itemCount: 5, // Adjust the count based on your design
        itemBuilder: (context, index) {
          return ListTileShimmer();
        },
      ),
    );
  }

  Widget _buildNoTodos() {
    return Center(
      child: Text('No todos added.'),
    );
  }

  Widget _buildTodoList() {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(todos[index]['text']),
          subtitle: Text('Category: ${todos[index]['category']}'),
          // Add other details as needed
        );
      },
    );
  }
}

class ListTileShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        width: 150,
        height: 15,
        color: Colors.grey[300],
      ),
      subtitle: Container(
        width: 100,
        height: 10,
        color: Colors.grey[300],
      ),
    );
  }
}

