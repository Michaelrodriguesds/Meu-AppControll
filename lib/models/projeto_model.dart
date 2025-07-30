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

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is String) return double.tryParse(value) ?? 0.0;
    if (value is num) return value.toDouble();
    if (value is Map && value.containsKey('\$numberDouble')) {
      return double.tryParse(value['\$numberDouble']) ?? 0.0;
    }
    return 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Projeto.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString(); // <-- CORRETO para o seu JSON

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
      dataInicio: _parseDate(json['start_date']),
      usuarioId: json['user_id'] ?? '',
      progresso: _parseDouble(json['progress']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': titulo,
      'description': descricao,
      'category': categoria,
      'required_value': valorNecessario,
      'applied_value': valorAplicado,
      'start_date': dataInicio.toIso8601String(),
      'user_id': usuarioId,
      'progress': progresso,
    };
  }
}
