import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UsuarioService {
  static const baseUrl = 'https://backendapp-0bcg.onrender.com/api';
  static Future<Usuario> obterPerfil(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/users/profile/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Usuario.fromJson(data);
    }

    throw Exception('Erro ao carregar perfil do usuário');
  }
}
