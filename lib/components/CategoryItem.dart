import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String category;
  final int todoCount;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  // Define a set for predefined categories
  static const Set<String> predefinedCategories = {
    'Birthdays',
    'Shopping',
    'Exercise',
    'Exams',
    'Events',
    'Savings',
    'Reading',
    'Meetings',
    'Trips',
    'Bills',
    'premade-Birthdays',
    'premade-Shopping',
    'premade-Exercise',
    'premade-Exams',
    'premade-Events',
    'premade-Savings',
    'premade-Reading',
    'premade-Meetings',
    'premade-Trips',
    'premade-Bills',
  };

  // Define a map to associate categories with colors
  static const Map<String, Color> categoryColors = {
    'Birthdays': Color.fromARGB(255, 255, 82, 82),
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

  // Define a map to associate categories with background images
  static const Map<String, String> categoryImages = {
    'Birthdays': 'assets/birthdays.png',
    'Shopping': 'assets/shopping.png',
    'Exercise': 'assets/exercise.png',
    'Exams': 'assets/exams.png',
    'Events': 'assets/events.png',
    'Savings': 'assets/savings.png',
    'Reading': 'assets/reading.png',
    'Meetings': 'assets/meetings.png',
    'Trips': 'assets/trips.png',
    'Bills': 'assets/bills.png',
    'premade-Birthdays': 'assets/birthdays.png',
    'premade-Shopping': 'assets/shopping.png',
    'premade-Exercise': 'assets/exercise.png',
    'premade-Exams': 'assets/exams.png',
    'premade-Events': 'assets/events.png',
    'premade-Savings': 'assets/savings.png',
    'premade-Reading': 'assets/reading.png',
    'premade-Meetings': 'assets/meetings.png',
    'premade-Trips': 'assets/trips.png',
    'premade-Bills': 'assets/bills.png',
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

    // Get the background image for the category, or use a default image
    String backgroundImage =
        categoryImages[displayCategory] ?? 'assets/custom.png';

    return InkWell(
      onTap: onTap,
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
            image: DecorationImage(
              image: AssetImage(backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                categoryColor!.withOpacity(0.6),
                BlendMode.xor,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: categoryColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    todoCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: categoryColor,
                ),
                child: Text(
                  displayCategory,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
