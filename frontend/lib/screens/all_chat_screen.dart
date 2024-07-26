// screens/all_chats_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

// screens/all_chats_screen.dart

class _AllChatsScreenState extends State<AllChatsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    final token = authProvider.token;
    if (token == null) {
      // Handle the case where token is null, e.g., redirect to login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      await chatProvider.fetchChats(token);
    } catch (e) {
      // Handle errors appropriately
      print('Error fetching chats: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Handle cases where token is still null
    final token = authProvider.token;
    if (token == null) {
      return Center(child: Text('Token is missing. Please log in again.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('All Chats'),
      ),
      body: chatProvider.chatUsers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: chatProvider.uniqueuser.length,
        itemBuilder: (context, index) {
          final user = chatProvider.uniqueuser[index];
          return Card(
            elevation: 5, // Adjust the elevation value for the card's shadow
            margin: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10), // Rounded corners for the card
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15), // Padding inside the card
              title: Text(
                  user['name'], style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user['email']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(userId: user['_id']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
