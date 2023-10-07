import 'package:flutter/material.dart';
import 'package:pub/screens/TodoListScreen.dart';

import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'screens/MainScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[900], // Adjust as needed
      ),
      initialRoute: '/',
      // routes: {
      //   '/': (context) => LoginPage(),
      //   '/home': (context) => MainScreen(),
      //   '/register': (context) => RegisterPage(),
      // },
      routes: {
        '/': (context) => MainScreen(),
      },
    );
  }
}
