// app/lib/requests.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestsScreen extends StatefulWidget {
  final Map userData;
  const RequestsScreen({super.key, required this.userData});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List incomingRequests = [];
  List sentRequests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    final myId = widget.userData['_id'];
    
    // 1. Fetch Incoming (Teacher View)
    final urlIncoming = Uri.parse('https://skillbarter-project.onrender.com/my-requests/$myId');
    // 2. Fetch Sent (Student View)
    final urlSent = Uri.parse('https://skillbarter-project.onrender.com/my-sent-requests/$myId');

    try {
      final resIncoming = await http.get(urlIncoming);
      final resSent = await http.get(urlSent);

      if (resIncoming.statusCode == 200 && resSent.statusCode == 200) {
        setState(() {
          incomingRequests = jsonDecode(resIncoming.body)['data'];
          sentRequests = jsonDecode(resSent.body)['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final url = Uri.parse('https://skillbarter-project.onrender.com');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requestId": id, "status": newStatus}),
    );
    fetchAllData(); // Refresh both lists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity"),
        backgroundColor: Colors.blueAccent,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Incoming (To Teach)"),
            Tab(text: "Sent (To Learn)"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: INCOMING REQUESTS
                _buildIncomingList(),

                // TAB 2: SENT REQUESTS
                _buildSentList(),
              ],
            ),
    );
  }

  Widget _buildIncomingList() {
    if (incomingRequests.isEmpty) return const Center(child: Text("No requests received."));
    
    return ListView.builder(
      itemCount: incomingRequests.length,
      itemBuilder: (context, index) {
        final req = incomingRequests[index];
        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(req['skillTitle'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Student: ${req['studentName']}"),
            trailing: req['status'] == 'Pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () => updateStatus(req['_id'], "Accepted")),
                      IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => updateStatus(req['_id'], "Rejected")),
                    ],
                  )
                : Text(req['status'], style: TextStyle(color: req['status'] == 'Accepted' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildSentList() {
    if (sentRequests.isEmpty) return const Center(child: Text("You haven't requested any skills yet."));

    return ListView.builder(
      itemCount: sentRequests.length,
      itemBuilder: (context, index) {
        final req = sentRequests[index];
        Color statusColor = Colors.orange;
        if (req['status'] == 'Accepted') statusColor = Colors.green;
        if (req['status'] == 'Rejected') statusColor = Colors.red;

        return Card(
          margin: const EdgeInsets.all(10),
          child: ListTile(
            title: Text(req['skillTitle'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Teacher: ${req['teacherName']}"),
            trailing: Chip(
              label: Text(req['status'], style: const TextStyle(color: Colors.white)),
              backgroundColor: statusColor,
            ),
          ),
        );
      },
    );
  }
}