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

  /// Fábrica que converte JSON em um objeto Anotacao
  factory Anotacao.fromJson(Map<String, dynamic> json) {
    // 🧠 Extrai o ID do formato MongoDB ou string comum
    String? idExtraido;

    if (json['id'] != null) {
      idExtraido = json['id'].toString();
    } else if (json['_id'] is Map && json['_id']['\$oid'] != null) {
      idExtraido = json['_id']['\$oid'];
    } else if (json['_id'] != null) {
      idExtraido = json['_id'].toString();
    }

    // 🚨 Se ainda não encontrou um ID válido, lança exceção
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

  /// Converte objeto Anotacao para JSON (para enviar ao backend)
  Map<String, dynamic> toJson() {
    return {
      'title': titulo,
      'content': conteudo,
      'date': data?.toIso8601String(),
      'user_id': usuarioId,
    };
  }

  /// Conversão segura para data a partir de string, timestamp ou formato MongoDB
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
