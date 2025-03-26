import 'package:flutter/material.dart';
import 'package:vetconnectapp/models/message_model.dart';
import 'package:vetconnectapp/core/services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService chatService;
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  ChatViewModel({
    required this.chatService,
  });

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void loadMessages(String conversationId) {
    _isLoading = true;
    notifyListeners();

    chatService.getMessages(conversationId).listen((messages) {
      _messages = messages;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String conversationId, String content, String receiverId) async {
    final message = MessageModel(
      id: DateTime.now().toString(),
      conversationId: conversationId,
      content: content,
      timestamp: DateTime.now(),
      senderId: 'currentUserId', // Replace with actual current user ID
      receiverId: receiverId,
    );

    await chatService.sendMessage(message);
    _messages.add(message);
    notifyListeners();
  }

  void receiveMessage(MessageModel message) {
    _messages.add(message);
    notifyListeners();
  }
}