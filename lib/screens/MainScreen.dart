// import 'package:flutter/material.dart';
// import 'package:dot_navigation_bar/dot_navigation_bar.dart';

// import 'CategoriesScreen.dart';
// import 'GlobalAddTodoScreen.dart';
// import 'HomeScreen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   // Define the screens for the bottom navigation bar
//   final List<Widget> _screens = [
//     HomeScreen(),
//     GlobalAddTodoScreen(),
//     CategoriesScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Pack ur Bag'),
//       ),
//       body: _screens[_currentIndex], // Show the selected screen
//       bottomNavigationBar: DotNavigationBar(
//         backgroundColor:Colors.amber,
//         currentIndex: _currentIndex,
//         onTap: (index) {
//           // Handle navigation when a tab is tapped
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: [
//             /// Home
//             DotNavigationBarItem(
//               icon: Icon(Icons.home),
//               selectedColor: Colors.purple,
//             ),

//             /// Likes
//             DotNavigationBarItem(
//               icon: Icon(Icons.favorite_border),
//               selectedColor: Colors.pink,
//             ),

//             /// Search
//             DotNavigationBarItem(
//               icon: Icon(Icons.search),
//               selectedColor: Colors.orange,
//             ),
//           ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:pub/screens/BluetoothChatScreen.dart';
import 'package:pub/screens/ChatGptScreen.dart';
import 'package:pub/screens/TodoListScreen.dart';
import 'CategoriesScreen.dart';
import 'GlobalAddTodoScreen.dart';
import 'HomeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Define the screens for the bottom navigation bar
  final List<Widget> _screens = [
    HomeScreen(),
    CategoriesScreen(),
    ChatGptScreen(),
    BluetoothChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Show the selected screen
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onFabPressed(context);
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  _onTabTapped(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.collections_bookmark_rounded),
                onPressed: () {
                  _onTabTapped(1);
                },
              ),
              SizedBox(), // The center space for the FAB
              IconButton(
                icon: Icon(Icons.chat),
                onPressed: () {
                  _onTabTapped(2);
                },
              ),
              IconButton(
                icon: Icon(Icons.connect_without_contact),
                onPressed: () {
                  _onTabTapped(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed(BuildContext context) {
    // Show the screen to add todos
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlobalAddTodoScreen(),
      ),
    );
  }
}


