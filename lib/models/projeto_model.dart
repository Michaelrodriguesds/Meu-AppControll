import 'transacao_model.dart';

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
  final List<Transacao> transacoes;

  const Projeto({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.valorNecessario,
    required this.valorAplicado,
    required this.dataInicio,
    required this.usuarioId,
    required this.progresso,
    this.transacoes = const [],
  });

  double get valorRestante => valorNecessario - valorAplicado;
  bool   get concluido     => progresso >= 100.0;

  /// Returns a copy with updated financial values (after a deposit).
  Projeto copyWithDeposit({
    required double newValue,
    required double progress,
    required Transacao transacao,
  }) =>
      Projeto(
        id:             id,
        titulo:         titulo,
        descricao:      descricao,
        categoria:      categoria,
        valorNecessario: valorNecessario,
        valorAplicado:  newValue,
        dataInicio:     dataInicio,
        usuarioId:      usuarioId,
        progresso:      progress,
        transacoes:     [transacao, ...transacoes],
      );

  factory Projeto.fromJson(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    if (id == null || id.isEmpty) throw Exception('ID do projeto ausente');

    return Projeto(
      id:              id,
      titulo:          json['title']       ?? '',
      descricao:       json['description'] ?? '',
      categoria:       json['category']    ?? '',
      valorNecessario: _toDouble(json['required_value']),
      valorAplicado:   _toDouble(json['applied_value']),
      progresso:       _toDouble(json['progress']),
      dataInicio:      _toDate(json['start_date']),
      usuarioId:       json['user_id']     ?? '',
      transacoes: (json['transactions'] as List? ?? [])
          .map((t) => Transacao.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title':         titulo,
        'description':   descricao,
        'category':      categoria,
        'required_value': valorNecessario,
        'applied_value':  valorAplicado,
        'start_date':    dataInicio.toIso8601String(),
        'user_id':       usuarioId,
      };

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num)  return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static DateTime _toDate(dynamic v) {
    if (v == null) return DateTime.now();
    if (v is String) return DateTime.tryParse(v) ?? DateTime.now();
    return DateTime.now();
  }
}

/// Response from POST /projects/{id}/deposit
class DepositResponse {
  final String projectId;
  final double previousValue;
  final double deposited;
  final double newValue;
  final double progress;
  final double requiredValue;

  const DepositResponse({
    required this.projectId,
    required this.previousValue,
    required this.deposited,
    required this.newValue,
    required this.progress,
    required this.requiredValue,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> j) => DepositResponse(
        projectId:     j['project_id'],
        previousValue: (j['previous_value'] as num).toDouble(),
        deposited:     (j['deposited'] as num).toDouble(),
        newValue:      (j['new_value'] as num).toDouble(),
        progress:      (j['progress'] as num).toDouble(),
        requiredValue: (j['required_value'] as num).toDouble(),
      );
}