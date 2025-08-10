// ignore_for_file: unnecessary_null_comparison

import 'package:intl/intl.dart';

/// Modelo que representa uma anotação com suporte a lembrete agendado.
class Anotacao {
  final String? id;             // ID da anotação (pode ser null para novas anotações)
  final String? titulo;         // Título da anotação
  final String? conteudo;       // Conteúdo da anotação
  final DateTime? data;         // Data associada à anotação (ex: criação ou agendamento)
  final DateTime? lembrete;     // ⏰ Lembrete/agendamento da anotação
  final String usuarioId;       // ID do usuário associado à anotação

  /// Construtor principal
  Anotacao({
    this.id,
    required this.usuarioId,
    this.titulo,
    this.conteudo,
    this.data,
    this.lembrete,
  });

  /// Construtor de fábrica para criar uma anotação a partir de um JSON
  factory Anotacao.fromJson(Map<String, dynamic> json) {
    // 📌 Extrai o ID da anotação com suporte a diferentes formatos (MongoDB etc.)
    String? idExtraido;

    if (json['id'] != null) {
      idExtraido = json['id'].toString();
    } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
      idExtraido = json['_id']['\$oid'];
    } else if (json['_id'] != null) {
      idExtraido = json['_id'].toString();
    }

    // Verifica se o ID foi extraído corretamente
    if (idExtraido == null || idExtraido.isEmpty) {
      throw Exception('ID da anotação ausente ou inválido: $json');
    }

    return Anotacao(
      id: idExtraido,
      usuarioId: json['user_id'] ?? json['usuarioId'] ?? '',
      titulo: json['title'] ?? json['titulo'],
      conteudo: json['content'] ?? json['conteudo'],
      data: _parseDate(json['date'] ?? json['data']),
      lembrete: _parseDate(json['reminder_at'] ?? json['lembrete']),
    );
  }

  /// Converte a instância da anotação em um mapa JSON para envio à API
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {
      'title': titulo,
      'content': conteudo,
      'date': data?.toIso8601String(),
      'user_id': usuarioId,
    };

    if (lembrete != null) {
      map['reminder_at'] = lembrete!.toIso8601String();
    }

    return map;
  }

  /// Método auxiliar para fazer parse de diferentes formatos de data
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is Map && value.containsKey('\$date')) {
      final d = value['\$date'];
      if (d is String) return DateTime.tryParse(d);
      if (d is Map && d.containsKey('\$numberLong')) {
        return DateTime.fromMillisecondsSinceEpoch(int.tryParse(d['\$numberLong']) ?? 0);
      }
    }

    return null;
  }

  /// Formata a data do lembrete para exibição legível (ex: 08/08/2025 14:00)
  String? get lembreteFormatado {
    if (lembrete == null) return null;
    return DateFormat('dd/MM/yyyy HH:mm').format(lembrete!);
  }
}
