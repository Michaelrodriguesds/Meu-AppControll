import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anotacao_model.dart';

class AnotacaoService {
  static const baseUrl = 'http://10.0.0.101:8000/api';

  // Listar todas as anotações do usuário
  static Future<List<Anotacao>> listar(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notes/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Anotacao.fromJson(e)).toList();
    }
    throw Exception('Erro ao carregar anotações');
  }

  // Criar nova anotação
  static Future<void> criar(Anotacao a, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(a.toJson()),
    );
    if (![200, 201].contains(res.statusCode)) {
      throw Exception('Erro ao criar anotação: ${res.body}');
    }
  }

  // Atualizar anotação existente
  static Future<void> atualizar(Anotacao a, String token) async {
    if (a.id == null || a.id!.isEmpty) {
      throw Exception('ID inválido para atualizar anotação');
    }

    final res = await http.put(
      Uri.parse('$baseUrl/notes/${a.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(a.toJson()),
    );

    if (res.statusCode != 200) {
      throw Exception('Erro ao atualizar anotação: ${res.body}');
    }
  }

  // Excluir anotação por ID
  static Future<void> deletar(String id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 204) {
      throw Exception('Erro ao excluir anotação: ${res.body}');
    }
  }
}
