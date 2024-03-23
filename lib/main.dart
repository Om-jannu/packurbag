import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:pub/screens/splashScreen.dart';
import 'pages/LoginPage.dart';
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

// import 'package:all_bluetooth/all_bluetooth.dart';
// import 'package:flutter/material.dart';
// import 'package:pub/pages/LoginPage.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() {
//   runApp(const MyApp());
// }

// const serverIp = "192.168.0.120";
// final allBluetooth = AllBluetooth();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Auth Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => AuthenticationScreen(),
//         '/home': (context) => HomeScreen(),
//         '/login': (context) => const LoginPage(),
//         '/signup': (context) => SignUpScreen(),
//         '/forgot_password': (context) => ForgotPasswordScreen(),
//       },
//     );
//   }
// }

// class AuthenticationScreen extends StatefulWidget {
//   const AuthenticationScreen({super.key});

//   @override
//   _AuthenticationScreenState createState() => _AuthenticationScreenState();
// }

// class _AuthenticationScreenState extends State<AuthenticationScreen> {
//   bool _isLoggedIn = false; // Check if user is logged in or not

//   @override
//   void initState() {
//     super.initState();
//     // Check if user is logged in
//     checkLoginStatus();
//   }

//   Future<void> checkLoginStatus() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     print("${prefs.getBool('isLoggedIn')}");
//     setState(() {
//       _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     });

//     if (_isLoggedIn) {
//       // If user is logged in, navigate to home directly
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacementNamed(context, '/home');
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Authentication'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/login');
//               },
//               child: const Text('Login'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/signup');
//               },
//               child: const Text('Sign Up'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pushNamed(context, '/forgot_password');
//               },
//               child: const Text('Forgot Password?'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       body: const Center(
//         child: Text('Welcome to Home Screen!'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Logout functionality
//           Navigator.pushReplacementNamed(context, '/');
//         },
//         child: const Icon(Icons.logout),
//       ),
//     );
//   }
// }

// class SignUpScreen extends StatelessWidget {
//   const SignUpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sign Up'),
//       ),
//       body: const Center(
//         child: Text('Sign Up Screen'),
//       ),
//     );
//   }
// }

// class ForgotPasswordScreen extends StatelessWidget {
//   const ForgotPasswordScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Forgot Password'),
//       ),
//       body: const Center(
//         child: Text('Forgot Password Screen'),
//       ),
//     );
//   }
// }
