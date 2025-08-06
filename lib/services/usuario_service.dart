import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'http://10.0.0.101:8000/api';

  static Future<bool> criarUsuario(Map<String, dynamic> usuario) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': usuario['nome'],
        'email': usuario['email'],
        'password': usuario['senha'],
        'theme': 'light',
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Erro ao criar usuário: ${response.statusCode}');
      print('Resposta: ${response.body}');
      return false;
    }
  }

  static Future<Map<String, dynamic>?> loginComUsuario(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': email,
          'password': senha,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'token': data['access_token'],
          'usuarioId': data['user']['id'], // <- Corrigido aqui
        };
      } else {
        print('Erro no login. Código: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUsuarioPorId(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Erro ao buscar usuário: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      return null;
    }
  }
}
