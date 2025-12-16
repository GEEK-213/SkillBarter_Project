// app/lib/home.dart

import 'package:flutter/material.dart';
import 'login.dart'; 
import 'add_skill.dart';

class HomeScreen extends StatelessWidget {
  final Map userData; 

  // Constructor
  const HomeScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkillBarter Dashboard"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout Logic
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
       
           
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Welcome back,", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    userData['name'], 
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Time Credits:", style: TextStyle(fontSize: 18)),
                      Text(
                        "${userData['wallet']}",
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- ACTION BUTTONS ---
            const Text("Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            Row(
              children: [
                
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       print("Find Skill Clicked");
                       
                    },
                    icon: const Icon(Icons.search),
                    label: const Text("Find Skill"),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ),
                
                const SizedBox(width: 10),
                
              
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                       
                       Navigator.push(
                         context, 
                         MaterialPageRoute(
                           builder: (context) => AddSkillScreen(
                             
                             userId: userData['_id'], 
                             userName: userData['name'],
                           ),
                         ),
                       );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Skill"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}