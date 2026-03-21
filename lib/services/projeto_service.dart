import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/projeto_model.dart';

class ProjetoService {
  static const _base = 'https://backendapp-0bcg.onrender.com/api';

  static Map<String, String> _headers(String token) => {
        'Authorization': 'Bearer $token',
        'Content-Type':  'application/json',
      };

  // ── List ──────────────────────────────────────────────────────────────────
  static Future<List<Projeto>> listar(String token) async {
    final res = await http.get(
      Uri.parse('$_base/projects/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao listar projetos');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Projeto.fromJson(j)).toList();
  }

  // ── Create ────────────────────────────────────────────────────────────────
  static Future<Projeto> criar(Projeto p, String token) async {
    final res = await http.post(
      Uri.parse('$_base/projects/'),
      headers: _headers(token),
      body:    jsonEncode(p.toJson()),
    );
    if (res.statusCode != 201) {
      final err = jsonDecode(res.body);
      throw Exception(err['detail'] ?? 'Erro ao criar projeto');
    }
    return Projeto.fromJson(jsonDecode(res.body));
  }

  // ── Update ────────────────────────────────────────────────────────────────
  static Future<Projeto> atualizar(Projeto p, String token) async {
    final res = await http.put(
      Uri.parse('$_base/projects/${p.id}'),
      headers: _headers(token),
      body:    jsonEncode(p.toJson()),
    );
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['detail'] ?? 'Erro ao atualizar projeto');
    }
    return Projeto.fromJson(jsonDecode(res.body));
  }

  // ── Delete ────────────────────────────────────────────────────────────────
  static Future<void> deletar(String id, String token) async {
    final res = await http.delete(
      Uri.parse('$_base/projects/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 204) throw Exception('Erro ao deletar projeto');
  }

  // ── Deposit (banking-style) ───────────────────────────────────────────────
  /// Sends only the [amount] to add — backend handles the sum.
  static Future<DepositResponse> depositar({
    required String projectId,
    required double amount,
    required String token,
    String note = '',
  }) async {
    final res = await http.post(
      Uri.parse('$_base/projects/$projectId/deposit'),
      headers: _headers(token),
      body:    jsonEncode({'amount': amount, 'note': note}),
    );
    if (res.statusCode != 200) {
      final err = jsonDecode(res.body);
      throw Exception(err['detail'] ?? 'Erro ao depositar');
    }
    return DepositResponse.fromJson(jsonDecode(res.body));
  }
}