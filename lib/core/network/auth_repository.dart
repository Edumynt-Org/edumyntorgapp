import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthRepository extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  // Dynamic base URL for local testing (Android emulator uses 10.0.2.2 for localhost)
  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:3000/api/users';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/users';
    return 'http://localhost:3000/api/users';
  }

  String? _token;
  bool _isLoading = true;

  AuthRepository(this._prefs) {
    _token = _prefs.getString('payload_token');
    _isLoading = false;
  }

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;

  Future<void> _setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _prefs.setString('payload_token', token);
    } else {
      await _prefs.remove('payload_token');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _setToken(null);
  }

  // Returns error message if fails, null if success
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        await _setToken(data['token']);
        return null;
      }

      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'][0]['message'];
      }
      
      return 'Invalid credentials';
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }

  // Returns error message if fails, null if success
  Future<String?> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Because verify: true is set on backend, they are NOT logged in automatically.
        // We just return success and let the UI handle the "Check email" step.
        return null;
      }

      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'][0]['message'];
      }
      
      return 'Registration failed';
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }

  Future<String?> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return null;
      }
      
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'].isNotEmpty) {
        return data['errors'][0]['message'];
      }
      return 'An error occurred';
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }
}
