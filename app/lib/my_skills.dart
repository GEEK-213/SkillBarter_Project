// app/lib/my_skills.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MySkillsScreen extends StatefulWidget {
  final Map userData;
  const MySkillsScreen({super.key, required this.userData});

  @override
  State<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends State<MySkillsScreen> {
  List mySkills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMySkills();
  }

  // 1. Fetch only MY skills
  Future<void> fetchMySkills() async {
    // We can reuse the get-skills API, but we need to filter client-side 
    // OR create a new specific API.
    // For simplicity, let's fetch all and filter here (Easy method)
    // A better way is server-side filtering, but this works for MVPs.
    
    final url = Uri.parse('http://10.0.2.2:3000/get-skills'); 
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final allSkills = data['data'] as List;
        
        setState(() {
          // FILTER: Only keep skills where teacherId == myId
          mySkills = allSkills.where((s) => s['teacherId'] == widget.userData['_id']).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // 2. Delete Logic
  Future<void> deleteSkill(String id) async {
    final url = Uri.parse('http://10.0.2.2:3000/delete-skill');
    await http.post(
      url, 
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"skillId": id})
    );
    fetchMySkills(); // Refresh list
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Skill Deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage My Skills")),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : mySkills.isEmpty 
          ? const Center(child: Text("You haven't posted any skills yet."))
          : ListView.builder(
              itemCount: mySkills.length,
              itemBuilder: (context, index) {
                final skill = mySkills[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(skill['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(skill['category']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteSkill(skill['_id']),
                    ),
                  ),
                );
              },
            ),
    );
  }
}