// ignore_for_file: unnecessary_null_comparison

class Anotacao {
  final String? id;
  final String? titulo;
  final String? conteudo;
  final DateTime? data;
  final String usuarioId;

  Anotacao({
    this.id,
    required this.usuarioId,
    this.titulo,
    this.conteudo,
    this.data,
  });

  /// Construtor de fábrica para criar uma instância a partir de um JSON
  factory Anotacao.fromJson(Map<String, dynamic> json) {
    // 📌 Tenta extrair o ID, seja ele normal ou no formato MongoDB
    String? idExtraido;

    if (json['id'] != null) {
      idExtraido = json['id'].toString();
    } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
      idExtraido = json['_id']['\$oid'];
    } else if (json['_id'] != null) {
      idExtraido = json['_id'].toString();
    }

    if (idExtraido == null || idExtraido.isEmpty) {
      throw Exception('ID da anotação ausente ou inválido: $json');
    }

    return Anotacao(
      id: idExtraido,
      usuarioId: json['user_id'] ?? json['usuarioId'] ?? '',
      titulo: json['title'] ?? json['titulo'],
      conteudo: json['content'] ?? json['conteudo'],
      data: _parseDate(json['date'] ?? json['data']),
    );
  }

  /// Método para converter a anotação em um JSON
  Map<String, dynamic> toJson() {
    return {
      'title': titulo,
      'content': conteudo,
      'date': data?.toIso8601String(),
      'user_id': usuarioId,
    };
  }

  /// Utilitário para parse seguro de datas em diferentes formatos
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
}
