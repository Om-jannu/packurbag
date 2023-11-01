import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pub/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/GlobalSnackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, var serverIp});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> signIn(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://$serverIp:5000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Successfully logged in
        print('Successfully logged in as '+usernameController.text);
        await saveUsername(usernameController.text);
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Handle invalid credentials
        print('Invalid credentials');
        GlobalSnackbar.show(context, 'Invalid credentials');
      }
    } else {
      // Handle login failure
      print('Login failed');
      GlobalSnackbar.show(
          context, 'Login failed. Please check your credentials');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => signIn(context),
              child: Text('Sign In'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

