import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PerfilScreen extends StatefulWidget {
  final String token;

  const PerfilScreen({super.key, required this.token});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Modelo básico do perfil
  late Future<UserProfile> _perfilFuture;
  bool _isDarkTheme = false; // controle simples do tema (pode salvar localmente depois)

  @override
  void initState() {
    super.initState();
    _perfilFuture = fetchUserProfile();
  }

  // Função para buscar perfil no backend
  Future<UserProfile> fetchUserProfile() async {
    final url = Uri.parse('https://seu-backend.com/perfil/'); // ajuste a URL da sua API

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      return UserProfile.fromJson(jsonBody);
    } else if (response.statusCode == 401) {
      throw Exception('Não autorizado. Faça login novamente.');
    } else {
      throw Exception('Falha ao carregar perfil');
    }
  }

  // Alterna tema claro/escuro (simplificado, só para exemplo)
  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  // Função para simular logout (retorna para tela login)
  void logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil 👤'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<UserProfile>(
        future: _perfilFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Carregando
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Erro ao carregar
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            // Nenhum dado encontrado
            return const Center(child: Text('Perfil não encontrado.'));
          }

          final perfil = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // Nome
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(perfil.nome),
                  subtitle: const Text('Nome'),
                ),
                const Divider(),

                // Email
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(perfil.email),
                  subtitle: const Text('E-mail'),
                ),
                const Divider(),

                // Tema com botão alternar
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: Text(_isDarkTheme ? 'Escuro' : 'Claro'),
                  subtitle: const Text('Tema'),
                  trailing: Switch(
                    value: _isDarkTheme,
                    onChanged: (val) => toggleTheme(),
                  ),
                ),
                const Divider(),

                // Projetos ativos
                ListTile(
                  leading: const Icon(Icons.bar_chart),
                  title: Text(perfil.projetosAtivos.toString()),
                  subtitle: const Text('Projetos Ativos'),
                ),
                const Divider(),

                // Total investido
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text('R\$ ${perfil.totalInvestido.toStringAsFixed(2)}'),
                  subtitle: const Text('Total Investido'),
                ),
                const Divider(),

                // Botão editar perfil
                ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  onPressed: () {
                    // TODO: Implementar tela de edição de perfil
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade ainda não implementada')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Botão sair da conta (logout)
                ElevatedButton.icon(
                  icon: const Icon(Icons.exit_to_app),
                  label: const Text('Sair da Conta'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: logout,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Modelo simples do perfil baseado no JSON esperado do backend
class UserProfile {
  final String nome;
  final String email;
  final int projetosAtivos;
  final double totalInvestido;

  UserProfile({
    required this.nome,
    required this.email,
    required this.projetosAtivos,
    required this.totalInvestido,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nome: json['nome'] ?? 'Sem nome',
      email: json['email'] ?? 'Sem email',
      projetosAtivos: json['projetos_ativos'] ?? 0,
      totalInvestido: (json['total_investido'] ?? 0).toDouble(),
    );
  }
}
