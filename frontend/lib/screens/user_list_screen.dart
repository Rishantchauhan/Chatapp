import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/api/users'),
      headers: {'Authorization': 'Bearer ${authProvider.token}'},
    );
    if (response.statusCode == 200) {
      setState(() {
        _users = jsonDecode(response.body);
        print('fetch user');
        print(_users);
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    print('Search User Called');
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/api/users/search?name=$query'),
      headers: {'Authorization':authProvider.token.toString()},
    );
    print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        _users = jsonDecode(response.body);
        print(_users[0]['_id']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Users',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _searchUsers(_searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  onTap: () {

                    Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(userId: user['_id'])));
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
