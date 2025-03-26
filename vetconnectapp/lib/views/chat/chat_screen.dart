import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    final String senderId = _auth.currentUser!.uid; // Correctly defined senderId
    final String conversationId = senderId.compareTo(widget.receiverId) < 0
        ? '$senderId${widget.receiverId}'
        : '${widget.receiverId}_$senderId';
    _fetchMessages(conversationId);
  }

  Future<void> sendMessage(String message) async {
    try {
      final String senderId = _auth.currentUser!.uid; // Correctly defined senderId
      final String conversationId = senderId.compareTo(widget.receiverId) < 0
          ? '$senderId${widget.receiverId}'
          : '${widget.receiverId}_$senderId';

      await _firestore.collection('conversations').doc(conversationId).collection('messages').add({
        'senderId': senderId,
        'receiverId': widget.receiverId,
        'message': message,
        'timestamp': Timestamp.now(),
      });

      log('Message sent successfully');
    } catch (e) {
      log('Error sending message: $e');
    }
  }

  Future<void> _fetchMessages(String conversationId) async {
    try {
      final querySnapshot = await _firestore
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _messages = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'messageId': doc.id,
            'senderId': data['senderId'] ?? '',
            'receiverId': data['receiverId'] ?? '',
            'message': data['message'] ?? '',
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
          };
        }).toList();
      });
    } catch (e) {
      log('Error fetching messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['message']),
                  subtitle: Text('From: ${message['senderId']}'),
                  trailing: Text(
                    message['timestamp'].toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        sendMessage(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void navigateToChatScreen(BuildContext context, String receiverId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(receiverId: receiverId),
    ),
  );
}