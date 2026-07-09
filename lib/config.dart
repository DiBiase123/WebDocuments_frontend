import 'package:flutter/foundation.dart';

class Config {
  static const Map<String, String> apiUrls = {
    'prod': 'https://orsocook-api.onrender.com',
    'local': 'http://localhost:5001',
  };

  static String get apiBaseUrl {
    if (kDebugMode) {
      return apiUrls['local']!;
    }
    return apiUrls['prod']!;
  }

  static String buildUrl([String endpoint = '']) {
    final base = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;

    if (endpoint.isEmpty) return base;
    final path = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$base/$path';
  }
}
