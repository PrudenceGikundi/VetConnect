import 'package:flutter/material.dart';
import 'package:vetconnectapp/views/chat/chat_screen.dart'; // Import ChatScreen

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> conversations = [
      {'name': 'Dr. Alaric Voss', 'lastMessage': 'Let\'s schedule your appointment...', 'receiverId': '1'},
      {'name': 'Dr. Beatrix Lin', 'lastMessage': 'Your test results are ready.', 'receiverId': '2'},
      {'name': 'Dr. Cillian Faulkner', 'lastMessage': 'I can see you at 3 PM.', 'receiverId': '3'},
      {'name': 'Dr. Dalia Marquez', 'lastMessage': 'Please confirm your appointment.', 'receiverId': '4'},
      {'name': 'Dr. Emmett Hawke', 'lastMessage': 'Follow up on your last visit.', 'receiverId': '5'},
      {'name': 'Dr. Fiona Kerr', 'lastMessage': 'Can you come in earlier?', 'receiverId': '6'},
      {'name': 'Dr. Gideon Price', 'lastMessage': 'Your prescription is ready.', 'receiverId': '7'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage('assets/doctor_placeholder.png'), // Replace with actual image
                  ),
                  title: Text(conversation['name'] ?? 'Unknown Doctor'),
                  subtitle: Text(conversation['lastMessage'] ?? 'No message'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('${index + 1}h ago'), // Replace with actual time
                      const Icon(Icons.circle, color: Colors.green, size: 10), // Online status
                    ],
                  ),
                  onTap: () {
                    // Navigate to chat screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(receiverId: conversation['receiverId'] ?? ''), // Pass the actual receiverId
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}