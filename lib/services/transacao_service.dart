import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transacao_model.dart';

class TransacaoService {
  static const _base = 'https://backendapp-0bcg.onrender.com/api';

  static Future<List<Transacao>> listar(String projectId, String token) async {
    final res = await http.get(
      Uri.parse('$_base/projects/$projectId/transactions'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar transações');
    final list = jsonDecode(res.body) as List;
    return list.map((j) => Transacao.fromJson(j)).toList();
  }
}