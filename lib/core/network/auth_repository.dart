import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class AuthRepository extends ChangeNotifier {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  // Base URL specifically for the Users collection endpoints
  String get _baseUrl => '${ApiConfig.baseUrl}/api/users';

  String? _token;
  String? _userName;
  bool _isLoading = true;

  AuthRepository(this._prefs, this._secureStorage, String? initialToken) {
    _token = initialToken;
    _userName = _prefs.getString('user_name');
    _isLoading = false;
  }

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userName => _userName;

  Future<void> _setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _secureStorage.write(key: 'payload_token', value: token);
    } else {
      await _secureStorage.delete(key: 'payload_token');
      await _prefs.remove('user_name');
      _userName = null;
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
        if (data['user'] != null && data['user']['name'] != null) {
          _userName = data['user']['name'];
          await _prefs.setString('user_name', _userName!);
        }
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
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
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
