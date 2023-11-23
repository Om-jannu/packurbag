// import 'package:flutter/material.dart';

// class CategoryItem extends StatelessWidget {
//   final String category;
//   final VoidCallback onDelete;
//   final VoidCallback onEdit;
//   final VoidCallback onTap;

//   const CategoryItem({
//     Key? key,
//     required this.category,
//     required this.onDelete,
//     required this.onEdit,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onTap,
//       child: Card(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(category),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.edit),
//                   onPressed: onEdit,
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.delete),
//                   onPressed: onDelete,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final int todoCount;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  // Define a set for predefined categories
  static const Set<String> predefinedCategories = {
    'Birthday',
    'Shopping',
    'Exercise',
    'Exams',
    'Events',
    'Savings',
    'Reading',
    'Meetings',
    'Trips',
    'Bills',
  };

  // Define a map to associate categories with colors
  static const Map<String, Color> categoryColors = {
    'Birthday': Color.fromARGB(255, 255, 82, 82),
    'Shopping': Colors.blueAccent,
    'Exercise': Color.fromARGB(200, 223, 64, 251),
    'Exams': Colors.deepOrangeAccent,
    'Events': Colors.yellowAccent,
    'Savings': Colors.greenAccent,
    'Reading': Colors.yellowAccent,
    'Meetings': Colors.lime,
    'Trips': Colors.blueGrey,
    'Bills': Colors.greenAccent,
  };

  const CategoryItem({
    Key? key,
    required this.category,
    required this.todoCount,
    required this.onLongPress,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the category is a premade category
    bool isPremadeCategory = category.startsWith("premade-");

    // Extract the relevant part of the category name
    String displayCategory =
        isPremadeCategory ? category.replaceFirst("premade-", "") : category;

    // Get the color for the category, or use a default color
    Color? categoryColor = categoryColors[displayCategory] ?? Colors.grey[300];

    return InkWell(
      onTap: onTap,
      // onDoubleTap: onEdit,
      onLongPress: () {
        // Check if the category is predefined before executing onLongPress
        if (!isPremadeCategory) {
          onLongPress();
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: categoryColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.grey,
                  ),
                ),
                child: Center(
                  child: Text(
                    todoCount.toString(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Text(
                displayCategory,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


