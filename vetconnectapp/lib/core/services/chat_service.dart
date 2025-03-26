import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vetconnectapp/models/message_model.dart';
import 'package:logger/logger.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();
  
  // Collection references
  final CollectionReference _conversationsCollection = 
      FirebaseFirestore.instance.collection('conversations');
  
  // Send a message
  Future<bool> sendMessage(MessageModel message) async {
    try {
      // Create a conversation ID if not provided
      String conversationId = message.conversationId ?? _generateConversationId(message.senderId, message.receiverId);
      
      // Set the conversation ID
      message.conversationId = conversationId;
      
      // Create the message in Firestore
      await _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .add(message.toMap());
      
      // Update conversation metadata
      await _updateConversationMetadata(conversationId, message);
      
      return true;
    } catch (e) {
      _logger.e('Error sending message: $e');
      return false;
    }
  }
  
  // Generate a conversation ID from two user IDs
  String _generateConversationId(String userId1, String userId2) {
    // Sort the IDs to ensure the same conversation ID regardless of who initiates
    List<String> sortedIds = [userId1, userId2]..sort();
    return "${sortedIds[0]}_${sortedIds[1]}";
  }
  
  // Update conversation metadata
  Future<void> _updateConversationMetadata(String conversationId, MessageModel message) async {
    try {
      // Get the other participant's ID
      String currentUserId = _auth.currentUser!.uid;
      String otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId;
      
      // Update conversation metadata
      await _conversationsCollection.doc(conversationId).set({
        'participantIds': [message.senderId, message.receiverId],
        'participants': {message.senderId: true, message.receiverId: true},
        'lastMessage': message.message,
        'lastSenderId': message.senderId,
        'lastTimestamp': message.timestamp,
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCount_$otherUserId': FieldValue.increment(1),
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.e('Error updating conversation metadata: $e');
    }
  }
  
  // Get messages for a conversation
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestore
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => MessageModel.fromMap(doc.data())).toList());
  }
  
  // Get all conversations for the current user
  Stream<QuerySnapshot> getConversations() {
    String uid = _auth.currentUser!.uid;
    
    return _conversationsCollection
        .where('participants.$uid', isEqualTo: true)
        .orderBy('updatedAt', descending: true)
        .snapshots();
  }
  
  // Get conversation ID between two users
  Future<String> getConversationId(String otherUserId) async {
    String currentUserId = _auth.currentUser!.uid;
    return _generateConversationId(currentUserId, otherUserId);
  }
  
  // Mark messages as read
  Future<bool> markMessagesAsRead(String conversationId) async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Update the conversation metadata to reset unread count
      await _conversationsCollection.doc(conversationId).update({
        'unreadCount_$uid': 0
      });
      
      // Mark all unread messages as read
      QuerySnapshot unreadMessages = await _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: uid)
          .where('isRead', isEqualTo: false)
          .get();
      
      // Use a batch write to update all messages
      WriteBatch batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      
      await batch.commit();
      return true;
    } catch (e) {
      _logger.e('Error marking messages as read: $e');
      return false;
    }
  }
  
  // Get unread message count for the current user
  Future<int> getUnreadMessageCount() async {
    try {
      String uid = _auth.currentUser!.uid;
      
      QuerySnapshot conversations = await _conversationsCollection
          .where('participants.$uid', isEqualTo: true)
          .get();
      
      int totalUnread = 0;
      
      for (var doc in conversations.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('unreadCount_$uid')) {
          totalUnread += (data['unreadCount_$uid'] as int);
        }
      }
      
      return totalUnread;
    } catch (e) {
      _logger.e('Error getting unread message count: $e');
      return 0;
    }
  }
  
  // Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    try {
      // Delete all messages in the conversation
      QuerySnapshot messages = await _conversationsCollection
          .doc(conversationId)
          .collection('messages')
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete the conversation document
      batch.delete(_conversationsCollection.doc(conversationId));
      
      await batch.commit();
      return true;
    } catch (e) {
      _logger.e('Error deleting conversation: $e');
      return false;
    }
  }
}