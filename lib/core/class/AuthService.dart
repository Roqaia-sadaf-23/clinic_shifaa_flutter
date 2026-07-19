import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/model/TokenModel.dart';
import '../constant/ApiLinks.dart';

class AuthService {
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _emailKey = 'email';
  static const String _roleNameKey = 'roleName';
  static const String _isLoggedInKey = 'isLoggedIn';

  /// تستخدم عند تحديث التوكنات، ولا تغيّر الدور.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_emailKey, email);
  }

  /// تستخدم بعد نجاح Login لحفظ الجلسة كاملة.
  static Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required String email,
    required String roleName,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_roleNameKey, roleName);
    await prefs.setBool(_isLoggedInKey, true);
  }

  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  static Future<String?> getRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleNameKey);
  }

  static Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      final email = await getEmail();

      if (refreshToken == null ||
          refreshToken.isEmpty ||
          email == null ||
          email.isEmpty) {
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiLinks.refreshToken),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken, 'email': email}),
      );

      if (response.statusCode != 200) {
        return false;
      }

      final body = jsonDecode(response.body);

      if (body is! Map) {
        return false;
      }

      final token = TokenModel.fromJson(Map<String, dynamic>.from(body));

      if (!token.isSuccess ||
          token.accessToken.isEmpty ||
          token.refreshToken.isEmpty) {
        return false;
      }

      // لا نحتاج إعادة حفظ roleName هنا؛ الدور محفوظ من Login.
      await saveTokens(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        email: email,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_roleNameKey);
    await prefs.remove(_isLoggedInKey);
  }
}
