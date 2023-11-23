import 'package:flutter/material.dart';
import 'package:pub/main.dart';
import 'package:pub/screens/BluetoothChatScreen.dart';
import 'package:pub/screens/GptScreen.dart';
import 'CategoriesScreen.dart';
import 'GlobalAddTodoScreen.dart';
import 'HomeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key,var serverIp}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Define the screens for the bottom navigation bar
  final List<Widget> _screens = [
    HomeScreen(serverIp: serverIp,),
    CategoriesScreen(serverIp: serverIp,),
    GptScreen(),
    BluetoothChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Show the selected screen
      floatingActionButtonLocation: _getFabLocation(),
      floatingActionButton: _buildFab(),
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

  Widget _buildFab() {
    // Disable FAB on GPT screen
    if (_currentIndex == 2) {
      return SizedBox.shrink(); // Return an empty container
    }else {
      // Default FAB for other screens
      return FloatingActionButton(
        onPressed: () {
          _onFabPressed(context);
        },
        child: Icon(Icons.add),
      );
    }
  }

  FloatingActionButtonLocation _getFabLocation() {
    // Change FAB position based on the current screen
    if (_currentIndex == 2) {
      return FloatingActionButtonLocation.endFloat;
    } else {
      return FloatingActionButtonLocation.centerDocked;
    }
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
        builder: (context) => GlobalAddTodoScreen(serverIp: serverIp,),
      ),
    );
  }

  void _onFabPressedGpt(BuildContext context) {
    // Custom functionality for the FAB on GPT screen
    // Add your GPT-specific action here
  }
}
