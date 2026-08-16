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

    if (_token != null) {
      _fetchProfileDetails();
    }
  }

  bool get isAuthenticated => _token != null;
  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get userName => _userName;
  String? get avatarUrl => _avatarUrl;

  Future<void> _fetchProfileDetails() async {
    if (_token == null) return;
    try {
      final meRes = await http.get(
        Uri.parse('$_baseUrl/me'),
        headers: {'Authorization': 'JWT $_token'},
      );
      if (meRes.statusCode == 200) {
        final data = jsonDecode(meRes.body);
        final user = data['user'];
        if (user != null) {
          if (user['name'] != null) {
            _userName = user['name'];
            await _prefs.setString('user_name', _userName!);
          }
          if (user['id'] != null) {
            try {
              debugPrint('Fetching profile for user: ${user['id']}');
              final profileRes = await http.get(
                Uri.parse(
                  '${ApiConfig.baseUrl}/api/profiles?where[user][equals]=${user['id']}',
                ),
                headers: {'Authorization': 'JWT $_token'},
              );
              debugPrint('Profile fetch status: ${profileRes.statusCode}');
              if (profileRes.statusCode == 200) {
                final profileData = jsonDecode(profileRes.body);
                if (profileData['docs'] != null &&
                    profileData['docs'].isNotEmpty) {
                  final profile = profileData['docs'][0];
                  if (profile['avatar'] != null) {
                    final avatarData = profile['avatar'];
                    debugPrint('Avatar data type: ${avatarData.runtimeType}');
                    if (avatarData is Map && avatarData['url'] != null) {
                      final url = avatarData['url'] as String;
                      _avatarUrl = url.startsWith('http')
                          ? url
                          : '${ApiConfig.baseUrl}$url';
                    } else if (avatarData is String) {
                      debugPrint('Fetching media for avatar ID: $avatarData');
                      final mediaRes = await http.get(
                        Uri.parse('${ApiConfig.baseUrl}/api/media/$avatarData'),
                      );
                      if (mediaRes.statusCode == 200) {
                        final mediaData = jsonDecode(mediaRes.body);
                        if (mediaData['url'] != null) {
                          final url = mediaData['url'] as String;
                          _avatarUrl = url.startsWith('http')
                              ? url
                              : '${ApiConfig.baseUrl}$url';
                        }
                      }
                    }
                    if (_avatarUrl != null) {
                      debugPrint('Successfully set avatar URL: $_avatarUrl');
                      await _prefs.setString('user_avatar', _avatarUrl!);
                    }
                  } else {
                    debugPrint('No avatar field in profile.');
                  }
                } else {
                  debugPrint('No profile document found for user.');
                }
              }
            } catch (e) {
              debugPrint('Error fetching profile: $e');
            }
          }
          notifyListeners();
        }
      }
    } catch (_) {}
  }

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
                  final avatarData = profile['avatar'];
                  if (avatarData is Map && avatarData['url'] != null) {
                    final url = avatarData['url'] as String;
                    _avatarUrl = url.startsWith('http')
                        ? url
                        : '${ApiConfig.baseUrl}$url';
                  } else if (avatarData is String) {
                    final mediaRes = await http.get(
                      Uri.parse('${ApiConfig.baseUrl}/api/media/$avatarData'),
                    );
                    if (mediaRes.statusCode == 200) {
                      final mediaData = jsonDecode(mediaRes.body);
                      if (mediaData['url'] != null) {
                        final url = mediaData['url'] as String;
                        _avatarUrl = url.startsWith('http')
                            ? url
                            : '${ApiConfig.baseUrl}$url';
                      }
                    }
                  }
                  if (_avatarUrl != null) {
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
