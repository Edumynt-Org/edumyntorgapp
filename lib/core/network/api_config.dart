import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // This allows you to override the URL at runtime using:
  // flutter run --dart-define=API_URL=https://edumynt.org
  static const String definedApiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    // 1. If an explicit URL was passed via command line, always use it
    if (definedApiUrl.isNotEmpty) {
      // Strip trailing slash if present just in case
      return definedApiUrl.endsWith('/')
          ? definedApiUrl.substring(0, definedApiUrl.length - 1)
          : definedApiUrl;
    }

    // 2. Default fallback logic for local development
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    return 'http://localhost:3000';
  }
}
