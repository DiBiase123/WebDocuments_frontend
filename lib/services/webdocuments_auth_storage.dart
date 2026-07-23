import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';
  static const String _roleKey = 'role';

  Future<void> saveAuthData({
    required String token,
    required String refreshToken,
    required String userId,
    required String username,
    String? role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    if (role != null) await prefs.setString(_roleKey, role);
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
      'role': prefs.getString(_roleKey) ?? 'USER',
    };
  }

  Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_roleKey);
  }
}
