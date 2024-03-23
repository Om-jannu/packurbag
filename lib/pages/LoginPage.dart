// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    final response = await http.post(
      Uri.parse('http://$serverIp:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userEmail': userEmailController.text,
        'password': passwordController.text,
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
        GlobalSnackbar.show(context, data['message'] ,success: true);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userEmailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => signIn(context),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RegisterPage(serverIp: serverIp),
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
