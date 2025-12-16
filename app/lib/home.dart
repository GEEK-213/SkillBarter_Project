// app/lib/home.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'add_skill.dart';
import 'requests.dart';

class HomeScreen extends StatefulWidget {
  final Map userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  List skills = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSkills(); 
  }

  Future<void> fetchSkills() async {
    // Use 10.0.2.2 for Android Emulator
    final url = Uri.parse('http://10.0.2.2:3000/get-skills');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          skills = data['data']; 
          isLoading = false;     
        });
      }
    } catch (e) {
      print("Error fetching skills: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("SkillBarter Feed"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSkills, 
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },

          ),
          IconButton(
            icon: const Icon(Icons.mail),
            onPressed: () {
               Navigator.push(
                 context, 
                 MaterialPageRoute(builder: (context) => RequestsScreen(userData: widget.userData))
               );
            },
          ),
        ],
      ),
    
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddSkillScreen(
               userId: widget.userData['_id'],
               userName: widget.userData['name'],
            )),
          ).then((_) => fetchSkills()); 
        },
        label: const Text("Teach a Skill"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          //  WELCOME SECTION
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.blue.shade50,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hello, ${widget.userData['name']}!", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("Wallet Balance: ${widget.userData['wallet']} Credits", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          //  THE MARKETPLACE LIST
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : skills.isEmpty 
                  ? const Center(child: Text("No skills found. Be the first to post!"))
                  : ListView.builder(
                      itemCount: skills.length,
                      itemBuilder: (context, index) {
                        final skill = skills[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blueAccent,
                              child: Text(skill['category'][0]),
                            ),
                            title: Text(skill['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(skill['description']),
                                const SizedBox(height: 5),
                                Text("Teacher: ${skill['teacherName']}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                            trailing: ElevatedButton(
                            
                              
                                onPressed: () async {
                              // 1. Define the URL
                              final url = Uri.parse('http://10.0.2.2:3000/request-skill');
                              
                              try {
                                // 2. Send the Booking Data
                                final response = await http.post(
                                  url,
                                  headers: {"Content-Type": "application/json"},
                                  body: jsonEncode({
                                    "studentId": widget.userData['_id'],
                                    "studentName": widget.userData['name'],
                                    "teacherId": skill['teacherId'],
                                    "teacherName": skill['teacherName'],
                                    "skillId": skill['_id'],
                                    "skillTitle": skill['title']
                                  }),
                                );

                                final result = jsonDecode(response.body);

                             
                                if (result['status'] == 'ok') {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Request Sent!"), backgroundColor: Colors.green)
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(result['message'] ?? "Error"), backgroundColor: Colors.red)
                                  );
                                }
                              } catch (e) {
                                print("Error: $e");
                              }
                            },
                          
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10)),
                              child: const Text("Request"),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

