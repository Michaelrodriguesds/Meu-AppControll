import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stats_model.dart';

class StatsService {
  static const _base = 'https://backendapp-0bcg.onrender.com/api';

  static Future<StatsSummary> buscar(String token) async {
    final res = await http.get(
      Uri.parse('$_base/stats/summary'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (res.statusCode != 200) throw Exception('Erro ao carregar estatísticas');
    return StatsSummary.fromJson(jsonDecode(res.body));
  }
}