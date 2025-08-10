import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anotacao_model.dart';

class AnotacaoService {
  // URL base da API (ajuste para seu ambiente)
  static const baseUrl = 'https://backendapp-0bcg.onrender.com/api';

  /// Lista todas as anotações do usuário autenticado
  /// Usa o token para autorização Bearer
  static Future<List<Anotacao>> listar(String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/notes/'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      // Mapeia cada item JSON para objeto Anotacao
      return data.map((e) => Anotacao.fromJson(e)).toList();
    }

    // Caso retorne erro, lança exceção com mensagem
    throw Exception('Erro ao carregar anotações');
  }

  /// Cria uma nova anotação enviando dados para a API
  static Future<void> criar(Anotacao a, String token) async {
    // Converte o objeto Anotacao para JSON usando o método toJson
    final body = jsonEncode(a.toJson());

    final res = await http.post(
      Uri.parse('$baseUrl/notes/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // Valida sucesso no status 200 (OK) ou 201 (Created)
    if (![200, 201].contains(res.statusCode)) {
      throw Exception('Erro ao criar anotação: ${res.body}');
    }
  }

  /// Atualiza uma anotação existente pelo ID
  static Future<void> atualizar(Anotacao a, String token) async {
    // Valida se anotação tem ID válido para atualização
    if (a.id == null || a.id!.isEmpty) {
      throw Exception('ID inválido para atualizar anotação');
    }

    final body = jsonEncode(a.toJson());

    final res = await http.put(
      Uri.parse('$baseUrl/notes/${a.id}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );

    // API deve retornar 200 para sucesso na atualização
    if (res.statusCode != 200) {
      throw Exception('Erro ao atualizar anotação: ${res.body}');
    }
  }

  /// Exclui uma anotação pelo seu ID
  static Future<void> deletar(String id, String token) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Status 204 indica exclusão com sucesso e sem conteúdo retornado
    if (res.statusCode != 204) {
      throw Exception('Erro ao excluir anotação: ${res.body}');
    }
  }
}
