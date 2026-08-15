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
  String? _avatarUrl;
  bool _isLoading = true;

  AuthRepository(this._prefs, this._secureStorage, String? initialToken) {
    _token = initialToken;
    _userName = _prefs.getString('user_name');
    _avatarUrl = _prefs.getString('user_avatar');
    _isLoading = false;
  }

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userName => _userName;
  String? get avatarUrl => _avatarUrl;

  Future<void> _setToken(String? token) async {
    _token = token;
    if (token != null) {
      await _secureStorage.write(key: 'payload_token', value: token);
    } else {
      await _secureStorage.delete(key: 'payload_token');
      await _prefs.remove('user_name');
      await _prefs.remove('user_avatar');
      _userName = null;
      _avatarUrl = null;
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
        final user = data['user'];
        if (user != null) {
          if (user['name'] != null) {
            _userName = user['name'];
            await _prefs.setString('user_name', _userName!);
          }

          // Attempt to fetch profile for avatar
          if (user['id'] != null) {
            try {
              final profileRes = await http.get(
                Uri.parse(
                  '${ApiConfig.baseUrl}/api/profiles?where[user][equals]=${user['id']}',
                ),
                headers: {'Authorization': 'JWT ${data['token']}'},
              );
              if (profileRes.statusCode == 200) {
                final profileData = jsonDecode(profileRes.body);
                if (profileData['docs'] != null &&
                    profileData['docs'].isNotEmpty) {
                  final profile = profileData['docs'][0];
                  if (profile['avatar'] != null &&
                      profile['avatar']['url'] != null) {
                    _avatarUrl =
                        '${ApiConfig.baseUrl}${profile['avatar']['url']}';
                    await _prefs.setString('user_avatar', _avatarUrl!);
                  }
                }
              }
            } catch (_) {
              // Ignore profile fetch failure
            }
          }
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
