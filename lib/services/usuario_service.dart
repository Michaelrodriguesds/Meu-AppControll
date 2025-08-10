import 'dart:convert';
import 'package:http/http.dart' as http;

/// Classe de serviço para lidar com autenticação e cadastro de usuários.
class UsuarioService {
  // URL base do seu backend (ajuste se necessário)
  static const String baseUrl = 'https://seu-backend.onrender.com/api';
  /// ===============================
  /// ✅ Função: Criar um novo usuário
  /// ===============================
  ///
  /// - Recebe um mapa com: nome, email, senha
  /// - Retorna:
  ///   - true → se criado com sucesso
  ///   - "email_ja_cadastrado" → se e-mail já estiver em uso
  ///   - false → para outros erros
  static Future<dynamic> criarUsuario(Map<String, dynamic> usuario) async {
    try {
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
        // Usuário criado com sucesso
        return true;
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        // Tratamento para e-mail já existente
        try {
          final body = jsonDecode(response.body);

          if (body is Map && body['detail'] != null) {
            final detail = body['detail'].toString().toLowerCase();

            if (detail.contains('email') || detail.contains('já existe')) {
              return 'email_ja_cadastrado';
            }
          }
        } catch (e) {
          print('Erro ao analisar resposta de erro: $e');
        }

        return false; // Erro genérico de validação
      } else {
        print('Erro ao criar usuário: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro inesperado ao criar usuário: $e');
      return false;
    }
  }

  /// ===============================
  /// ✅ Função: Login de usuário
  /// ===============================
  ///
  /// - Envia e-mail e senha para autenticação
  /// - Retorna:
  ///   - Map com token e ID do usuário → se login for bem-sucedido
  ///   - null → em caso de falha
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
          'usuarioId': data['user']['id'],
        };
      } else {
        print('Erro no login. Código: ${response.statusCode}');
        print('Resposta: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro inesperado no login: $e');
      return null;
    }
  }

  /// ===============================
  /// ✅ Função: Buscar usuário por ID
  /// ===============================
  ///
  /// - Utilizada para obter os dados de um usuário específico
  /// - Retorna:
  ///   - Map com dados do usuário → se sucesso
  ///   - null → em caso de erro
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
