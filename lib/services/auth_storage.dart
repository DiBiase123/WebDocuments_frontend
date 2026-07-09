import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';

  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
  }

  Future<Map<String, String>?> loadAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    return {
      'token': token,
      'refreshToken': prefs.getString(_refreshTokenKey) ?? '',
      'userId': prefs.getString(_userIdKey) ?? '',
      'username': prefs.getString(_usernameKey) ?? '',
    };
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
  }
}
