import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pub/main.dart';
import 'package:pub/screens/calculator_screen.dart';
import 'package:pub/screens/currencyConverter.dart';
import 'BluetoothChatScreen.dart';
import 'GptScreen.dart';
import 'CategoriesScreen.dart';
import 'GlobalAddTodoScreen.dart';
import 'HomeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, var serverIp}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(serverIp: serverIp),
    CategoriesScreen(serverIp: serverIp),
    GptScreen(),
    BluetoothChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButtonLocation: _getFabLocation(),
      floatingActionButton: _buildSpeedDial(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: 60,
        shape: CircularNotchedRectangle(),
        notchMargin: 8,
        child: Container(
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
              SizedBox(),
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

  Widget _buildSpeedDial() {
    // Disable FAB on GPT screen
    if (_currentIndex == 2) {
      return const SizedBox.shrink(); // Return an empty container
    } else {
      // Default FAB for other screens
      return SpeedDial(
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add), // Replace with your icon
            label: 'Add Todo',
            onTap: () {
              _onFabPressed(context);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.calculate), // Replace with your icon
            label: 'Calculator',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalculatorScreen(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child:
                const Icon(Icons.currency_exchange), // Replace with your icon
            label: 'Currency Converter',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CurrencyConverter()),
              );
            },
          ),
        ],
        child: const Icon(Icons.add),
      );
    }
  }

  FloatingActionButtonLocation _getFabLocation() {
    return FloatingActionButtonLocation.centerDocked;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onFabPressed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GlobalAddTodoScreen(serverIp: serverIp),
      ),
    );
  }
}
