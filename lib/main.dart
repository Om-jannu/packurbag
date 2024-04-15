import 'package:flutter/material.dart';
import 'package:pub/screens/splashScreen.dart';
import 'package:torch_controller/torch_controller.dart';
import 'pages/LoginPage.dart';
import 'screens/MainScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TorchController().initialize();
  runApp(const MyApp());
}

const serverIp = "https://8eb9-103-219-166-102.ngrok-free.app";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.grey[900], // Adjust as needed
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      // initialRoute: '/',
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const MainScreen(
              serverIp: serverIp,
            ),
      },
    );
  }
}
