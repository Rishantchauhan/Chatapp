// screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileProvider()..fetchUserDetails(),
      child: ProfileView(),
    );
  }
}

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              profileProvider.logout(context);
            },
          ),
        ],
      ),
      body: profileProvider.users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: profileProvider.users.length,
        itemBuilder: (context, index) {
          final user = profileProvider.users[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Name: ${user['name']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Email: ${user['email']}'),
                    SizedBox(height: 8),
                    Text('Phone Number: ${user['phoneNumber'] ?? 'Not available'}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
