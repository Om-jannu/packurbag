import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController worldAnimationController;

  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    worldAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Start the animation
    worldAnimationController.forward();

    // Wait for the animation to complete before checking login status
    worldAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        checkLoginStatus();
      }
    });
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });

    if (_isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    // Dispose the animation controller when it's no longer needed
    worldAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your custom logo widget
            Lottie.asset(
              "assets/animations/world.json",
              controller: worldAnimationController,
            ),
            const SizedBox(height: 20), // Add some space between logo and text
            // Your custom text widget
            const Text(
              'PackUrBag',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
