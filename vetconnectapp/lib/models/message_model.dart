import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  String? conversationId; // Add conversationId field
  final String content;
  final DateTime timestamp;
  final String senderId;
  final String receiverId;

  MessageModel({
    required this.id,
    this.conversationId, // Add conversationId to constructor
    required this.content,
    required this.timestamp,
    required this.senderId,
    required this.receiverId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId, // Add conversationId to map
      'content': content,
      'timestamp': timestamp,
      'senderId': senderId,
      'receiverId': receiverId,
    };
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'],
      conversationId: map['conversationId'], // Add conversationId from map
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      senderId: map['senderId'],
      receiverId: map['receiverId'],
    );
  }

  String get message => content; // Add message getter
}