class Usuario {
  final String id;
  final String nome;
  final String email;
  final String tema;
  final int    projetosAtivos;
  final double totalInvestido;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tema,
    required this.projetosAtivos,
    required this.totalInvestido,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id:             json['id']?.toString() ?? json['_id']?['\$oid'] ?? '',
      nome:           json['name']  ?? '',
      email:          json['email'] ?? '',
      tema:           json['theme'] ?? 'light',
      projetosAtivos: (json['projects_count'] ?? 0) as int,
      totalInvestido: (json['total_invested'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name':           nome,
        'email':          email,
        'theme':          tema,
        'projects_count': projetosAtivos,
        'total_invested': totalInvestido,
      };
}