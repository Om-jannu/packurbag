import 'package:flutter/material.dart';
import 'package:pub/screens/splashScreen.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/LoginPage.dart';
import 'screens/MainScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  TorchController().initialize();
  runApp(const MyApp());
}

const serverIp = "https://7639-103-26-57-127.ngrok-free.app";

class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: SharedPreferences.getInstance().then((prefs) => prefs.getString('userId') ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return MainScreen(
          serverIp: serverIp,
          userId: snapshot.data ?? '',
        );
      },
    );
  }
}

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
        '/home': (context) => const MainScreenWrapper(),
      },
    );
  }
}
