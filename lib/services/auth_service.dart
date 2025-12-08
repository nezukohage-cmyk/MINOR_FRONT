// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService {
  static const String _jwtKey = "jwt_token";

  // ------------------------
  // SIGNUP
  // ------------------------
  static Future<Map<String, dynamic>> signup({
    required String name,      // this stays the same internally
    required String email,
    required String password,
    required String phone,
  }) async {
    final res = await Api().postJson(
      "/auth/signup",
      body: {
        "username": name,    // ✔ FIXED
        "email": email,
        "password": password,
        "phone": phone,
      },
    );

    // Save token if backend returns it
    final token = res["token"];
    if (token != null) {
      await Api().setToken(token);
    }

    return res;
  }

  // ------------------------
  // LOGIN
  // ------------------------
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await Api().postJson(
      "/auth/login",
      body: {
        "identifier": email,
        "password": password,
      },
    );

    final token = res["token"];
    if (token != null) {
      await Api().setToken(token);
    }

    return res;
  }

  // ------------------------
  // GET CURRENT USER (/auth/me)
  // ------------------------
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await Api().get("/auth/me");
    return res;
  }

  // ------------------------
  // LOGOUT
  // ------------------------
  static Future<void> logout() async {
    await Api().clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_jwtKey);
  }

  // ------------------------
  // CHECK IF LOGGED IN
  // ------------------------
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_jwtKey);
    return token != null && token.isNotEmpty;
  }
}
