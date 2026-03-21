import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/usuario_model.dart';

class UsuarioService {
  static const String _base = 'https://backendapp-0bcg.onrender.com/api';

  // ── Criar usuário ──────────────────────────────────────────────────────────
  static Future<dynamic> criarUsuario(Map<String, dynamic> usuario) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/users/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name':     usuario['nome'],
          'email':    usuario['email'],
          'password': usuario['senha'],
          'theme':    'light',
        }),
      );
      if (res.statusCode == 201) return true;
      if (res.statusCode == 400 || res.statusCode == 409) {
        try {
          final body = jsonDecode(res.body);
          if (body is Map && body['detail'] != null) {
            final detail = body['detail'].toString().toLowerCase();
            if (detail.contains('email') || detail.contains('já existe')) {
              return 'email_ja_cadastrado';
            }
          }
        } catch (_) {}
        return false;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao criar usuário: $e');
      return false;
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> loginComUsuario(
      String email, String senha) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': email, 'password': senha},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          'token':     data['access_token'],
          'usuarioId': data['user']['id'],
        };
      }
      return null;
    } catch (e) {
      debugPrint('Erro no login: $e');
      return null;
    }
  }

  // ── Buscar por ID ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUsuarioPorId(String id) async {
    try {
      final res = await http.get(Uri.parse('$_base/users/$id'));
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar usuário: $e');
      return null;
    }
  }

  // ── Obter perfil via token ─────────────────────────────────────────────────
  static Future<Usuario> obterPerfil(String token) async {
    final res = await http.get(
      Uri.parse('$_base/users/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(res.body));
    }
    throw Exception('Erro ao carregar perfil');
  }
}