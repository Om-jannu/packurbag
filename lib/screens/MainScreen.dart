import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pub/main.dart';
import 'package:pub/screens/BtScreen.dart';
import 'package:pub/pages/addTodoPage.dart';
import 'package:pub/screens/calculator_screen.dart';
import 'package:pub/screens/currencyConverter.dart';
import 'package:pub/screens/profilePage.dart';
import 'package:pub/screens/temp.dart';
import 'package:pub/screens/translationPage.dart';
import 'package:quick_actions/quick_actions.dart';
import 'GptScreen.dart';
import 'CategoriesScreen.dart';
import 'HomeScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key, var serverIp}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final quickActions = const QuickActions();
  @override
  void initState() {
    super.initState();
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
      }
    });
  }

  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = [
    const HomeScreen(serverIp: serverIp),
    const CategoriesPage(),
    const TranslationPage(),
    const BtScreen(),
    const ProfilePage(),
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
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

  Widget _buildSpeedDial() {
    if (_currentIndex == 2 || _currentIndex == 3) {
      return const SizedBox.shrink(); // Return an empty container
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
