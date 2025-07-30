import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/projeto_model.dart';

class ProjetoService {
  static const String baseUrl = 'http://10.0.0.101:8000/api';

  static Future<List<Projeto>> getProjetos({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Projeto.fromJson(json)).toList();
    }

    throw Exception('Erro ao carregar projetos (${response.statusCode})');
  }

  static Future<void> criarProjeto(Projeto p, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/projects/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(p.toJson()),
    );

    if (![200, 201].contains(response.statusCode)) {
      throw Exception('Erro ao criar projeto: ${response.body}');
    }
  }

  static Future<void> atualizarProjeto(Projeto p, String token) async {
    if (p.id == null || p.id!.isEmpty) {
      throw Exception('Projeto sem ID válido para atualização');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/projects/${p.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(p.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao atualizar projeto: ${response.body}');
    }
  }

  static Future<void> deletarProjeto(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Erro ao excluir projeto (${response.statusCode}): ${response.body}');
    }
  }
}
