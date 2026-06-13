import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/ApiLinks.dart';

class AuthService {
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("accessToken", accessToken);
    await prefs.setString("refreshToken", refreshToken);
    await prefs.setString("email", email);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refreshToken");
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("email");
  }

  static Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      final email = await getEmail();

      if (refreshToken == null || email == null) {
        return false;
      }

      final response = await http.post(
        Uri.parse(ApiLinks.refreshToken),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken, "email": email}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        final accessToken = body["token"]["accessToken"];
        final newRefreshToken = body["token"]["refreshToken"];

        await saveTokens(
          accessToken: accessToken,
          refreshToken: newRefreshToken,
          email: email,
        );

        return true;
      }

      return false;
    } catch (e) {
      print("REFRESH TOKEN ERROR: $e");
      return false;
    }
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");
    await prefs.remove("email");
  }
}
