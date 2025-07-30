class Usuario {
  final String id;
  final String nome;
  final String email;
  final int projetosAtivos;
  final double totalInvestido;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.projetosAtivos,
    required this.totalInvestido,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nome: json['name'] ?? '',
      email: json['email'] ?? '',
      projetosAtivos: json['projects_count'] ?? 0,
      totalInvestido: (json['total_applied'] ?? 0).toDouble(),
    );
  }
}
