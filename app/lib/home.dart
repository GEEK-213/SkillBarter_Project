// app/lib/home.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'add_skill.dart';
import 'requests.dart';
import 'my_skills.dart';

class HomeScreen extends StatefulWidget {
  final Map userData;

  const HomeScreen({super.key, required this.userData});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List skills = [];
  List filteredSkills = [];
  bool isLoading = true;
  String selectedCategory = "All";
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = ["All", "Coding", "Music", "Cooking", "Academics", "Art"];

  @override
  void initState() {
    super.initState();
    fetchSkills();
  }

  // --- API LOGIC ---
  Future<void> fetchSkills([String query = ""]) async {
    // FIX 1: Switched back to Emulator Localhost. 
    // Change this to your Render URL only when you are ready to deploy.
    String urlString = 'http://10.0.2.2:3000/get-skills'; 
    
    if (query.isNotEmpty) {
      urlString += "?search=$query";
    }

    try {
      final response = await http.get(Uri.parse(urlString));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          skills = data['data'];
          
          // Apply Category Filter
          if (selectedCategory != "All") {
             filteredSkills = skills.where((s) => (s['category'] ?? "General") == selectedCategory).toList();
          } else {
             filteredSkills = skills;
          }
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching skills: $e");
    }
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (category == "All") {
        filteredSkills = skills;
      } else {
        // FIX 2: Added null check (?? "General") to prevent crash on old data
        filteredSkills = skills.where((s) => (s['category'] ?? "General") == category).toList();
      }
    });
  }

  Future<void> requestSkill(Map skill) async {
    // FIX 3: Switched back to Emulator Localhost
    final url = Uri.parse('https://skillbarter-project.onrender.com');
    
    try {
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
      if (!mounted) return;

      if (result['status'] == 'ok') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Error"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  // --- HELPER: Get Image based on Category ---
  String getCategoryImage(String? category) {
    // FIX 4: Handle if category is null
    if (category == null) return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500';

    switch (category) {
      case 'Coding': return 'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=500';
      case 'Music': return 'https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=500';
      case 'Cooking': return 'https://images.unsplash.com/photo-1507048331197-7d4ac70811cf?w=500';
      case 'Academics': return 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=500';
      case 'Art': return 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=500';
      default: return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("SkillBarter", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MySkillsScreen(userData: widget.userData))),
          ),
          IconButton(
            icon: const Icon(Icons.mail_outline),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RequestsScreen(userData: widget.userData))),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AddSkillScreen(
               userId: widget.userData['_id'],
               userName: widget.userData['name'],
          ))).then((_) => fetchSkills());
        },
        label: const Text("Teach"),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.black87,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. WELCOME & SEARCH
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         const Text("Hello,", style: TextStyle(color: Colors.grey)),
                         Text(widget.userData['name'] ?? "User", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.shade100)),
                      child: Row(children: [
                        const Icon(Icons.bolt, color: Colors.green, size: 20),
                        // FIX 5: Handle wallet being null
                        Text("${widget.userData['wallet'] ?? 0} Credits", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ]),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search skills...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) => fetchSkills(value),
                ),
              ],
            ),
          ),

          // 2. CATEGORY CHIPS
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => filterByCategory(cat),
                    selectedColor: Colors.black,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              },
            ),
          ),

          // 3. SKILL LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredSkills.isEmpty
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.search_off, size: 40, color: Colors.grey), const SizedBox(height: 10), const Text("No skills found.")]))
                    : ListView.builder(
                        itemCount: filteredSkills.length,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        itemBuilder: (context, index) {
                          return _buildProCard(filteredSkills[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildProCard(Map skill) {
    // FIX 6: Safety checks for missing data
    final title = skill['title'] ?? "Untitled";
    final category = skill['category'] ?? "General";
    final description = skill['description'] ?? "No description";
    final teacher = skill['teacherName'] ?? "Unknown";

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        image: DecorationImage(
          image: NetworkImage(getCategoryImage(category)),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, 
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(5)),
                  child: Text(category, style: const TextStyle(color: Colors.white, fontSize: 12)),
                ),
                const SizedBox(height: 5),
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(description, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.white, size: 16),
                        const SizedBox(width: 5),
                        Text(teacher, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => requestSkill(skill),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                      ),
                      child: const Text("Request"),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}