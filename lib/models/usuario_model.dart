// usuario.dart - modelo de usuário no frontend

class Usuario {
  final String id;
  final String nome;
  final String email;
  final String tema; // ex: claro ou escuro
  final int projetosAtivos;
  final double totalInvestido;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.tema,
    required this.projetosAtivos,
    required this.totalInvestido,
  });

  // Convertendo JSON do backend para o modelo Dart, com mapeamento dos campos corretos
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['_id']?['\$oid'] ?? '', // MongoDB ObjectId dentro de _id
      nome: json['name'] ?? '',
      email: json['email'] ?? '',
      tema: json['theme'] ?? 'claro',
      projetosAtivos: json['projects_count'] ?? 0,
      totalInvestido: (json['total_invested'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convertendo modelo Dart para JSON (para enviar ao backend se precisar)
  Map<String, dynamic> toJson() {
    return {
      'name': nome,
      'email': email,
      'theme': tema,
      'projects_count': projetosAtivos,
      'total_invested': totalInvestido,
    };
  }
}
