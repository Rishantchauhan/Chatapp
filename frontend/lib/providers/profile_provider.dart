// providers/profile_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider with ChangeNotifier {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  Future<void> fetchUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token not found');
      }
       print('In Profile');
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/api/users/get'),
        headers: {
          'Authorization': token,
        },
      );
      // print(response.body);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        _users = data.map((user) => {
          'id': user['_id'],
          'name': user['name'],
          'email': user['email'],
          'phoneNumber': user['phoneNumber'], // Add this field if available
        }).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    // Optionally clear other session data if needed
    Navigator.pushReplacementNamed(context, '/login');
  }
}
