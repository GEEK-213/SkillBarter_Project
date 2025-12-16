// app/lib/add_skill.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddSkillScreen extends StatefulWidget {
  final String userId; 
  final String userName;

  const AddSkillScreen({super.key, required this.userId, required this.userName});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  
 
  String selectedCategory = "Coding"; 
  final List<String> categories = ["Coding", "Music", "Cooking", "Academics", "Art"];

  Future<void> postSkill() async {
    // Android Emulator URL
    final url = Uri.parse('http://10.0.2.2:3000/add-skill');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": titleController.text,
          "description": descController.text,
          "category": selectedCategory,
          "teacherId": widget.userId,  
          "teacherName": widget.userName 
        }),
      );

      final data = jsonDecode(response.body);

      if (data['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skill Posted Successfully!")));
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to post skill")));
      }

    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Skill")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("What can you teach?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // Title Input
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Skill Title (e.g., Python Basics)",
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 15),

            // Category Dropdown
            DropdownButtonFormField(
              initialValue: selectedCategory,
              items: categories.map((String cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (newValue) {
                setState(() { selectedCategory = newValue!; });
              },
              decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),

            // Description Input
            TextField(
              controller: descController,
              maxLines: 3, 
              decoration: const InputDecoration(
                labelText: "Description (Time, Requirements...)",
                border: OutlineInputBorder()
              ),
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: postSkill,
                icon: const Icon(Icons.cloud_upload),
                label: const Text("Post Skill"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }
}