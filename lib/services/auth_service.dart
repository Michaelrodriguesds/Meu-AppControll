import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _base         = 'https://backendapp-0bcg.onrender.com/api';
  static const _keyToken     = 'auth_token';
  static const _keyUserId    = 'auth_user_id';
  static const _keyEmail     = 'auth_email';
  static const _keyBiometric = 'biometric_enabled';

  static final LocalAuthentication _localAuth = LocalAuthentication();

  // ── Login com e-mail e senha ───────────────────────────────────────────────
  static Future<Map<String, String>?> login(String email, String password) async {
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

    // Ativa biometria automaticamente se dispositivo suporta
    try {
      final available = await _localAuth.canCheckBiometrics;
      final enrolled  = await _localAuth.getAvailableBiometrics();
      if (available && enrolled.isNotEmpty) await enableBiometric();
    } catch (_) {}

    return {'token': token, 'userId': userId};
  }

  // ── Valida token contra o backend ─────────────────────────────────────────
  static Future<bool> validateToken(String token) async {
    if (token.isEmpty) return false;
    try {
      final res = await http.get(
        Uri.parse('$_base/users/profile/'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (_) {
      // Sem internet — mantém sessão (não desloga por falta de conexão)
      return true;
    }
  }

  // ── Biometria ─────────────────────────────────────────────────────────────
  static Future<bool> canUseBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token == null) return false;
    try {
      final available = await _localAuth.canCheckBiometrics;
      final enrolled  = await _localAuth.getAvailableBiometrics();
      return available && enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, String>?> loginWithBiometric() async {
    final authenticated = await _localAuth.authenticate(
      localizedReason: 'Use sua digital para entrar',
      options: const AuthenticationOptions(biometricOnly: true),
    );
    if (!authenticated) return null;

    final prefs  = await SharedPreferences.getInstance();
    final token  = prefs.getString(_keyToken);
    final userId = prefs.getString(_keyUserId);
    if (token == null || userId == null) return null;

    // Verifica se token ainda é válido
    final valid = await validateToken(token);
    if (!valid) {
      await logout();
      return null;
    }

    return {'token': token, 'userId': userId};
  }

  static Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometric, true);
  }

  // ── Sessão ────────────────────────────────────────────────────────────────
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
    // Mantém e-mail e flag biométrica para próximo login
  }
}