import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _base        = 'https://backendapp-0bcg.onrender.com/api';
  static const _keyToken    = 'auth_token';
  static const _keyUserId   = 'auth_user_id';
  static const _keyEmail    = 'auth_email';
  static const _keyBio      = 'biometric_enabled';

  static final _localAuth = LocalAuthentication();

  // ── Login com e-mail e senha ───────────────────────────────────────────────
  static Future<Map<String, String>?> login(
      String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': password},
      );
      if (res.statusCode != 200) return null;

      final data   = jsonDecode(res.body);
      final token  = data['access_token'] as String;
      final userId = data['user']['id']   as String;

      await _saveSession(token: token, userId: userId, email: email);
      return {'token': token, 'userId': userId};
    } catch (e) {
      debugPrint('Erro no login: $e');
      return null;
    }
  }

  // ── Biometria ──────────────────────────────────────────────────────────────
  static Future<bool> canUseBiometric() async {
    final prefs   = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_keyBio) ?? false;
    if (!enabled) return false;
    return await _localAuth.canCheckBiometrics;
  }

  static Future<Map<String, String>?> loginWithBiometric() async {
    final ok = await _localAuth.authenticate(
      localizedReason: 'Use sua digital para entrar',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (!ok) return null;

    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString(_keyToken);
    final userId = prefs.getString(_keyUserId);
    if (token == null || userId == null) return null;
    return {'token': token, 'userId': userId};
  }

  static Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBio, true);
  }

  // ── Sessão ─────────────────────────────────────────────────────────────────
  static Future<void> _saveSession({
    required String token,
    required String userId,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken,  token);
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyEmail,  email);
  }

  static Future<Map<String, String>?> getSavedSession() async {
    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString(_keyToken);
    final userId = prefs.getString(_keyUserId);
    if (token == null || userId == null) return null;
    return {'token': token, 'userId': userId};
  }

  static Future<String> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail) ?? '';
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
  }
}