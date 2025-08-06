class Projeto {
  final String? id;
  final String titulo;
  final String descricao;
  final String categoria;
  final String usuarioId;
  final double valorNecessario;
  final double valorAplicado;
  final double progresso;
  final DateTime dataInicio;

  Projeto({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.valorNecessario,
    required this.valorAplicado,
    required this.dataInicio,
    required this.usuarioId,
    required this.progresso,
  });

  /// Conversão de JSON para Projeto
  factory Projeto.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();

    if (id == null || id.isEmpty) {
      throw Exception('ID do projeto ausente ou inválido');
    }

    return Projeto(
      id: id,
      titulo: json['title'] ?? '',
      descricao: json['description'] ?? '',
      categoria: json['category'] ?? '',
      valorNecessario: _parseDouble(json['required_value']),
      valorAplicado: _parseDouble(json['applied_value']),
      progresso: _parseDouble(json['progress']),
      dataInicio: _parseDate(json['start_date']),
      usuarioId: json['user_id'] ?? '',
    );
  }

  /// Conversão de Projeto para JSON
  Map<String, dynamic> toJson() {
    return {
      'title': titulo,
      'description': descricao,
      'category': categoria,
      'required_value': valorNecessario,
      'applied_value': valorAplicado,
      'progress': progresso,
      'start_date': dataInicio.toIso8601String(),
      'user_id': usuarioId,
    };
  }

  /// Converte valores dinâmicos em double com segurança
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    if (value is Map && value.containsKey('\$numberDouble')) {
      return double.tryParse(value['\$numberDouble']) ?? 0.0;
    }
    return 0.0;
  }

  /// Converte datas recebidas em vários formatos
  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}
