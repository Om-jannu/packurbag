import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../components/GlobalSnackbar.dart';

class RegisterPage extends StatefulWidget {
  final String serverIp;

  const RegisterPage({Key? key, required this.serverIp}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  Future<void> register(BuildContext context) async {
    if (passwordController.text != confirmPasswordController.text) {
      GlobalSnackbar.show(context, 'Passwords do not match');
      return;
    }

    // Basic validation for email format
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(emailController.text)) {
      GlobalSnackbar.show(context, 'Invalid email address');
      return;
    }

    // Show loading indicator
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Registering...')));

    final response = await http.post(
      Uri.parse('http://${widget.serverIp}:5000/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text,
        "userEmail": emailController.text,
        'password': passwordController.text,
      }),
    );

    // Hide loading indicator
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Successfully registered
        print('Successfully registered');
        await saveUsername(usernameController.text);
        GlobalSnackbar.show(context, '${data['message']}', success: true);
        Navigator.pop(context); // Navigate back to login page
      } else {
        // Handle registration failure
        print('Registration failed');
        GlobalSnackbar.show(
            context, 'Registration failed. Please try a different username.');
      }
    } else {
      // Handle registration failure
      print('Registration failed');
      GlobalSnackbar.show(
          context, 'Registration failed. Please try again later.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Page'),
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
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => register(context),
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
