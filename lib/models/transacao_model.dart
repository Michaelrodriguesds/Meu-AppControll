class Transacao {
  final String id;
  final String projectId;
  final double amount;
  final String note;
  final DateTime createdAt;

  const Transacao({
    required this.id,
    required this.projectId,
    required this.amount,
    this.note = '',
    required this.createdAt,
  });

  factory Transacao.fromJson(Map<String, dynamic> json) => Transacao(
        id:        json['id']?.toString() ?? '',
        projectId: json['project_id']?.toString() ?? '',
        amount:    (json['amount'] as num).toDouble(),
        note:      json['note'] ?? '',
        createdAt: DateTime.parse(json['created_at']),
      );
}