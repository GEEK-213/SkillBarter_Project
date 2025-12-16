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

class _RequestsScreenState extends State<RequestsScreen> {
  List requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
   
    final url = Uri.parse('http://10.0.2.2:3000/my-requests/${widget.userData['_id']}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          requests = data['data'];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final url = Uri.parse('http://10.0.2.2:3000/update-request');
    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"requestId": id, "status": newStatus}),
    );
    fetchRequests(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incoming Requests")),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : requests.isEmpty 
          ? const Center(child: Text("No requests yet."))
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(req['skillTitle'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Student: ${req['studentName']}\nStatus: ${req['status']}"),
                    isThreeLine: true,
                    trailing: req['status'] == 'Pending' 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => updateStatus(req['_id'], "Accepted"),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => updateStatus(req['_id'], "Rejected"),
                            ),
                          ],
                        )
                      : null,
                  ),
                );
              },
            ),
    );
  }
}