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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _isAuthenticated = _token != null;
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> _removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<bool> register(String email, String password, String name, String phoneNumber) async {
    print(dotenv.env['API_URL']);
    print('http://192.168.8.96:3000/api/auth/signup');
    final response = await http.post(
      Uri.parse('http://192.168.8.96:3000/api/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phoneNumber': phoneNumber,
      }),
    );
    print(response.body);
    return response.statusCode == 201;
  }

  Future<bool> login(String email, String password) async {
    print('login');
    final response = await http.post(
      Uri.parse('http://192.168.8.96:3000/api/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    print(response.body);
    if (response.statusCode == 200) {
      _token = jsonDecode(response.body)['token'];
      _isAuthenticated = true;
      await _saveToken(_token!);
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  void logout() async {
    _token = null;
    _isAuthenticated = false;
    await _removeToken();
    notifyListeners();
  }
}
