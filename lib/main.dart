import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:pub/screens/MonthlyTodoScreen.dart';
import 'pages/LoginPage.dart';
import 'pages/RegisterPage.dart';
import 'screens/MainScreen.dart';

void main() {
  runApp(const MyApp());
}

const serverIp = "192.168.0.120";
final allBluetooth = AllBluetooth();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.grey[900], // Adjust as needed
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(
              serverIp: serverIp,
            ),
        '/home': (context) => MainScreen(
              serverIp: serverIp,
            ),
        '/register': (context) => RegisterPage(
              serverIp: serverIp,
            ),
      },
      // routes: {
      //   '/': (context) => DailyScreen(),
      // },
    );
  }
}
