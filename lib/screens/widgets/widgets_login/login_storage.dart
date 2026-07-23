import 'package:flutter/foundation.dart';
import 'package:webdocuments/dev_credentials.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginStorage {
  static Future<Map<String, dynamic>> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final resetDone = prefs.getBool('reset_done') ?? false;
    if (resetDone) {
      await prefs.setBool('reset_done', false);
      await prefs.setBool('remember_me', true);
    }
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');
    final rememberMe = prefs.getBool('remember_me') ?? false;
    if (rememberMe && savedEmail != null) {
      return {
        'email': savedEmail,
        'password': savedPassword ?? '',
        'rememberMe': true,
      };
    }
    if (kDebugMode) {
      return {
        'email': DevCredentials.email,
        'password': DevCredentials.password,
        'rememberMe': false,
      };
    }
    return {'email': '', 'password': '', 'rememberMe': false};
  }

  static Future<void> saveCredentials(
    String email,
    String password,
    bool rememberMe,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }
}
