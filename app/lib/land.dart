// app/lib/landing.dart

import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart'; // We will create this file in Step 2!

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 40),
              
              // --- HERO IMAGE / ICON ---
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.handshake_rounded, 
                    size: 100, 
                    color: Colors.blueAccent
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // --- WELCOME TEXT ---
              Column(
                children: [
                  const Text(
                    "SkillBarter",
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Teach what you know.\nLearn what you love.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16, 
                      color: Colors.grey.shade600,
                      height: 1.5
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // --- ACTION BUTTONS ---
              Column(
                children: [
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // Register Button (Outlined)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.blueAccent, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text("Create Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}