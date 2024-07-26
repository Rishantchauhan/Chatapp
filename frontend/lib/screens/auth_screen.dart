import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isAuthenticated = false;
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name, String phoneNumber) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phoneNumber': phoneNumber,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}/api/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      _token = jsonDecode(response.body)['token'];
      _isAuthenticated = true;
      notifyListeners();
      _saveToken(_token!);
      return true;
    } else {
      return false;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token);
  }

  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
  }
}
