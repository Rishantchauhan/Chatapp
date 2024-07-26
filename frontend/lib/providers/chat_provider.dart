import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';

// providers/chat_provider.dart

class ChatProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;
  final List<String> _chatUsers = [];
  List<String> get chatUsers => _chatUsers;
  late IO.Socket _socket;
  List<dynamic>uniqueuser=[];

  ChatProvider() {
    _initSocket();
  }

  void _initSocket() {
    _socket = IO.io('${dotenv.env['API_URL']}', IO.OptionBuilder()
        .setTransports(['websocket'])
        .build());

    _socket.onConnect((_) {
      print('Connected to server');
    });

    _socket.on('message', (data) {
      _messages.add(data);
      notifyListeners();
    });
  }

  // providers/chat_provider.dart

  Future<void> fetchChats(String token) async {
  if (token == null) {
  throw Exception('Token is null');
  }

  final url = Uri.parse('${dotenv.env['API_URL']}/api/messages');
  final response = await http.get(
  url,
  headers: {
  'Content-Type': 'application/json',
  'Authorization': token,
  },
  );
  if (response.statusCode == 200) {
  uniqueuser= List<dynamic>.from(json.decode(response.body));
  print(uniqueuser);
  notifyListeners();
  } else {
  throw Exception('Failed to load chats');
  }
  }



  Future<void> fetchMessages(String receiverId, String token) async {
    print('fetch Message Called');
    final url = Uri.parse('${dotenv.env['API_URL']}/api/messages/$receiverId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': token,
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      _messages.clear();
      List<Map<String, dynamic>> fetchedMessages = List<Map<String, dynamic>>.from(
        json.decode(response.body),
      );
      _messages.addAll(fetchedMessages);
      notifyListeners();
    } else {
      throw Exception('Failed to load messages');
    }
  }

  void sendMessage(String senderId, String receiverId, String message) {
    print('send Message Called');
    if (message.isNotEmpty) {
      _socket.emit('message', {'senderId': senderId, 'receiverId': receiverId, 'text': message});
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }
}
