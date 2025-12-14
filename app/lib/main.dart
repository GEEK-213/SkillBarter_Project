import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert'; 
import 'login.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
    home: const LoginScreen(),
    ),
  );
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> registerUser() async {
    // URL for Android Emulator is 10.0.2.2
    // testing on Web, change this to 'http://localhost:3000/register'
    final url = Uri.parse('http://10.0.2.2:3000/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": nameController.text,
          "email": emailController.text,
          "password": passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        print(" SUCCESS: Data sent to server!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User Registered Successfully!')),
        );
      } else {
        print(" FAILED: Server rejected it.");
      }
    } catch (e) {
      print(" ERROR: Could not connect. Is server running? $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SkillBarter Register")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Name Input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // Email Input
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Password Input
            TextField(
              controller: passwordController,
              obscureText: true, 
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // Register Button
            ElevatedButton(
              onPressed: registerUser,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ), // Full width button
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text("Join SkillBarter"),
            ),
          ],
        ),
      ),
    );
  }
}
