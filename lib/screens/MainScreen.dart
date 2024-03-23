// import 'package:flutter/material.dart';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:pub/main.dart';
// import 'package:pub/screens/BtScreen.dart';
// import 'package:pub/screens/calculator_screen.dart';
// import 'package:pub/screens/currencyConverter.dart';
// import 'GptScreen.dart';
// import 'CategoriesScreen.dart';
// import 'GlobalAddTodoScreen.dart';
// import 'HomeScreen.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key, var serverIp}) : super(key: key);

//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     const HomeScreen(serverIp: serverIp),
//     const CategoriesScreen(serverIp: serverIp),
//     GptScreen(),
//     const BtScreen(),
//   ];
//   void _onItemTapped(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       floatingActionButton: _buildSpeedDial(),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//         showUnselectedLabels: false,
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.house),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.layerGroup),
//             label: 'Category',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.diceD20),
//             label: 'AI',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.comments),
//             label: 'Bluetooth',
//           ),
//           BottomNavigationBarItem(
//             icon: FaIcon(FontAwesomeIcons.user),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSpeedDial() {
//     // Disable FAB on GPT screen
//     if (_currentIndex == 2 || _currentIndex == 3) {
//       return const SizedBox.shrink(); // Return an empty container
//     } else {
//       // Default FAB for other screens
//       return SpeedDial(
//         children: [
//           SpeedDialChild(
//             child: const Icon(Icons.add),
//             shape: const CircleBorder(), // Replace with your icon
//             label: 'Add Todo',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       const GlobalAddTodoScreen(serverIp: serverIp),
//                 ),
//               );
//             },
//           ),
//           SpeedDialChild(
//             child: const FaIcon(
//                 FontAwesomeIcons.calculator), // Replace with your icon
//             shape: const CircleBorder(),
//             label: 'Calculator',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const CalculatorScreen(),
//                 ),
//               );
//             },
//           ),
//           SpeedDialChild(
//             child: const FaIcon(
//                 FontAwesomeIcons.moneyBillTransfer), // Replace with your icon
//             shape: const CircleBorder(),
//             label: 'Currency Converter',
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => const CurrencyConverter()),
//               );
//             },
//           ),
//         ],
//         child: const FaIcon(FontAwesomeIcons.gear),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pub/main.dart';
import 'package:pub/screens/BtScreen.dart';
import 'package:pub/screens/addTodoPage.dart';
import 'package:pub/screens/calculator_screen.dart';
import 'package:pub/screens/colorPicker.dart';
import 'package:pub/screens/currencyConverter.dart';
import 'package:pub/screens/profilePage.dart';
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
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    themeMode = ThemeMode.light;
  }

  int _currentIndex = 0;
  PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = [
    const HomeScreen(serverIp: serverIp),
    const CategoriesScreen(serverIp: serverIp),
    GptScreen(),
    const BtScreen(),
    const ProfilePage()
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
              FontAwesomeIcons.house,
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
              FontAwesomeIcons.diceD20,
              size: 18.0,
            ),
            label: 'AI',
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
              FontAwesomeIcons.moneyBillTransfer,
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
              FontAwesomeIcons.colonSign,
              size: 18,
            ),
            shape: const CircleBorder(),
            label: 'Color Picker',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ColorPickerPage()),
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
