import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:pub/pages/RegisterPage.dart';
import 'package:pub/screens/MainScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/GlobalSnackbar.dart';
import '../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoggedIn = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("${prefs.getBool('isLoggedIn')}");
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });

    if (_isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(serverIp: serverIp),
        ),
      );
    }
  }

  TextEditingController userEmailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> saveUserDetails(
      String userId, String username, String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', userId);
    await prefs.setString('username', username);
    await prefs.setString('userEmail', userEmail);
  }

  Future<void> signIn(BuildContext context) async {
    String userEmail = userEmailController.text.trim();
    String password = passwordController.text.trim();

    // Validate email
    if (userEmail.isEmpty) {
      GlobalSnackbar.show(context, 'Please enter your email');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(userEmail)) {
      GlobalSnackbar.show(context, 'Invalid email address');
      return;
    }

    // Validate password
    if (password.isEmpty) {
      GlobalSnackbar.show(context, 'Please enter your password');
      return;
    }

    final response = await http.post(
      Uri.parse('$serverIp/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userEmail': userEmail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      if (data['success']) {
        final userData = data['data'];
        await saveUserDetails(
            userData['_id'], userData['username'], userData['userEmail']);
        Navigator.pushReplacementNamed(context, '/home');
        GlobalSnackbar.show(context, data['message'], success: true);
      } else {
        GlobalSnackbar.show(context, data['message']);
      }
    } else {
      print('Login failed');
      GlobalSnackbar.show(
          context, 'Login failed. Please check your credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Lottie.asset(
                  height: 300,
                  "assets/animations/login.json",
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: userEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed: () => signIn(context),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Don't have an account ?",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  side: const BorderSide(color: Colors.white),
                  backgroundColor: Colors.transparent,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegisterPage(serverIp: serverIp),
                  ),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
