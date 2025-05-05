import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pub/screens/BtScreen.dart';
import 'package:pub/pages/addTodoPage.dart';
import 'package:pub/screens/calculator_screen.dart';
import 'package:pub/screens/currencyConverter.dart';
import 'package:pub/screens/profilePage.dart';
import 'package:pub/screens/translationPage.dart';
import 'package:quick_actions/quick_actions.dart';
import 'GptScreen.dart';
import 'CategoriesScreen.dart';
import 'HomeScreen.dart';
import 'ExpenseTrackerScreen.dart';

class MainScreen extends StatefulWidget {
  final String serverIp;
  final String userId;
  const MainScreen({
    Key? key,
    required this.serverIp,
    required this.userId,
  }) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final quickActions = const QuickActions();
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const CategoriesPage(),
      const TranslationPage(),
      const BtScreen(),
      const ProfilePage(),
    ];
    
    quickActions.setShortcutItems([
      const ShortcutItem(
          type: "translator", localizedTitle: "Translator", icon: "translator"),
      const ShortcutItem(
          type: "currency_converter",
          localizedTitle: "Currency Converter",
          icon: "currency_converter"),
      const ShortcutItem(
          type: "calculator", localizedTitle: "Calculator", icon: "calculator"),
      const ShortcutItem(
          type: "addTodo", localizedTitle: "Add Todo", icon: "add_todo"),
      const ShortcutItem(
          type: "expense_tracker",
          localizedTitle: "Expense Tracker",
          icon: "expense_tracker"),
    ]);
    
    quickActions.initialize((type) {
      if (type == "addTodo") {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AddTodoPage()));
      } else if (type == "calculator") {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CalculatorScreen()));
      } else if (type == "currency_converter") {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CurrencyConverter()));
      } else if (type == "translator") {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const TranslationPage()));
      } else if (type == "expense_tracker") {
        Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExpenseTrackerScreen(
                userId: widget.userId,
                serverIp: widget.serverIp,
              ),
            ));
      }
    });
  }

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: _buildSpeedDial(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.rectangleList,
              size: 18.0,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.layerGroup,
              size: 18.0,
            ),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.earthAmericas,
              size: 18.0,
            ),
            label: 'Translator',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.comments,
              size: 18.0,
            ),
            label: 'Bluetooth',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(
              FontAwesomeIcons.user,
              size: 18.0,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _buildSpeedDial() {
    if (_currentIndex == 2 || _currentIndex == 3) {
      return const SizedBox.shrink();
    } else {
      return SpeedDial(
        children: [
          SpeedDialChild(
            child: const FaIcon(
              FontAwesomeIcons.penToSquare,
              size: 18,
            ),
            shape: const CircleBorder(),
            label: 'Add Todo',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTodoPage(),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const FaIcon(
              FontAwesomeIcons.calculator,
              size: 18,
            ),
            shape: const CircleBorder(),
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
            child: const FaIcon(
              FontAwesomeIcons.wallet,
              size: 18,
            ),
            shape: const CircleBorder(),
            label: 'Currency Converter',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CurrencyConverter()),
              );
            },
          ),
          SpeedDialChild(
            child: const FaIcon(
              FontAwesomeIcons.moneyBill,
              size: 18,
            ),
            shape: const CircleBorder(),
            label: 'Expense Tracker',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseTrackerScreen(
                    userId: widget.userId,
                    serverIp: widget.serverIp,
                  ),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const FaIcon(
              FontAwesomeIcons.diceD20,
              size: 18,
            ),
            shape: const CircleBorder(),
            label: 'AI',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GptScreen()),
              );
            },
          ),
        ],
        child: const FaIcon(
          FontAwesomeIcons.gear,
          size: 20,
        ),
      );
    }
  }
}
