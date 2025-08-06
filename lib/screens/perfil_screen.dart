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
  late Future<UserProfile> _perfilFuture;
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _perfilFuture = fetchUserProfile();
  }

  /// Função que busca os dados do perfil via API
  Future<UserProfile> fetchUserProfile() async {
    final url = Uri.parse('https://seu-backend.com/perfil/'); // 🔁 Substitua pela sua URL real

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

  /// Alterna entre tema claro e escuro (sem persistência)
  void toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  /// Faz logout e retorna para tela de login
  void logout() {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Perfil não encontrado.'));
          }

          final perfil = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 🪪 Nome
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(perfil.nome, style: theme.textTheme.titleMedium),
                  subtitle: const Text('Nome completo'),
                ),
              ),

              // 📧 Email
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: Text(perfil.email),
                  subtitle: const Text('E-mail de cadastro'),
                ),
              ),

              // 🎨 Tema
              Card(
                child: ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Tema do App'),
                  subtitle: Text(_isDarkTheme ? 'Escuro' : 'Claro'),
                  trailing: Switch(
                    value: _isDarkTheme,
                    onChanged: (val) => toggleTheme(),
                  ),
                ),
              ),

              // 📊 Projetos ativos
              Card(
                child: ListTile(
                  leading: const Icon(Icons.workspaces_outline),
                  title: Text('${perfil.projetosAtivos} projetos'),
                  subtitle: const Text('Projetos ativos'),
                ),
              ),

              // 💰 Total investido
              Card(
                child: ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: Text('R\$ ${perfil.totalInvestido.toStringAsFixed(2)}'),
                  subtitle: const Text('Total investido'),
                ),
              ),

              const SizedBox(height: 24),

              // ✏️ Botão editar perfil (não implementado)
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade ainda não implementada')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),

              const SizedBox(height: 12),

              // 🚪 Botão sair
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Modelo de dados do perfil de usuário
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
