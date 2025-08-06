import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/projeto_service.dart';
import 'configuracoes_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String usuarioId;

  const HomeScreen({
    super.key,
    required this.token,
    required this.usuarioId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String nomeUsuario = '';
  String emailUsuario = '';
  String temaUsuario = '';
  bool carregando = true;
  bool erro = false;

  double totalInvestido = 0.0;
  int totalProjetos = 0;

  @override
  void initState() {
    super.initState();
    carregarUsuario();
    carregarProjetos();
  }

  // Carrega dados do usuário
  Future<void> carregarUsuario() async {
    try {
      final usuario = await UsuarioService.getUsuarioPorId(widget.usuarioId);

      if (usuario != null) {
        setState(() {
          nomeUsuario = usuario['name'] ?? '';
          emailUsuario = usuario['email'] ?? '';
          temaUsuario = usuario['theme'] ?? '';
        });
      } else {
        setState(() {
          erro = true;
        });
        mostrarErro('Erro ao carregar dados do usuário.');
      }
    } catch (e) {
      setState(() {
        erro = true;
      });
      mostrarErro('Erro ao carregar usuário: $e');
    } finally {
      setState(() {
        carregando = false;
      });
    }
  }

  // Carrega e soma os valores dos projetos do usuário
 Future<void> carregarProjetos() async {
  try {
    final projetos = await ProjetoService.getProjetos(token: widget.token);
    double soma = 0.0;

    for (var projeto in projetos) {
      // valorAplicado nunca será nulo, então não precisamos do ?? 0.0
      soma += projeto.valorAplicado;
    }

    setState(() {
      totalProjetos = projetos.length;
      totalInvestido = soma;
    });
  } catch (e) {
    // Aqui você pode exibir um erro com SnackBar se quiser alertar o usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar projetos: $e')),
    );
    print('Erro ao carregar projetos: $e');
  }
}


  // Exibe snackbar de erro
  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Confirmação de logout
  void confirmarLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal.shade700,
        title: Text(
          nomeUsuario.isNotEmpty ? 'Bem-vindo, $nomeUsuario' : 'Carregando...',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                nomeUsuario.isNotEmpty ? nomeUsuario[0].toUpperCase() : 'U',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            onSelected: (value) {
              if (value == 'config') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ConfiguracoesScreen(
                      nome: nomeUsuario,
                      email: emailUsuario,
                      theme: temaUsuario,
                      onLogout: confirmarLogout,
                    ),
                  ),
                );
              } else if (value == 'logout') {
                confirmarLogout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'config',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Configurações'),
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro
              ? const Center(
                  child: Text('Erro ao carregar dados.\nTente novamente.', textAlign: TextAlign.center),
                )
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // DASHBOARD FINANCEIRO
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Resumo Financeiro',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                _DashboardCard(
                                  icon: Icons.attach_money,
                                  label: 'Total Investido',
                                  value: 'R\$ ${totalInvestido.toStringAsFixed(2)}',
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                _DashboardCard(
                                  icon: Icons.flag,
                                  label: 'Projetos',
                                  value: totalProjetos.toString(),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // AÇÕES RÁPIDAS
                    Text('Ações Rápidas',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.add_circle,
                      title: 'Novo Projeto',
                      subtitle: 'Crie um novo projeto com metas.',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/projeto_form',
                        arguments: {'usuarioId': widget.usuarioId, 'token': widget.token},
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ActionCard(
                      icon: Icons.note_add,
                      title: 'Nova Anotação',
                      subtitle: 'Salve lembretes ou ideias.',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/anotacao_form',
                        arguments: {'usuarioId': widget.usuarioId, 'token': widget.token},
                      ),
                    ),
                    const SizedBox(height: 30),

                    // LINKS ÚTEIS
                    _LinkTile(
                      icon: Icons.folder,
                      label: 'Ver Projetos',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/projetos',
                        arguments: {'token': widget.token},
                      ),
                    ),
                    const SizedBox(height: 10),
                    _LinkTile(
                      icon: Icons.note,
                      label: 'Ver Anotações',
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/anotacoes',
                        arguments: {'usuarioId': widget.usuarioId, 'token': widget.token},
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
    );
  }
}

// COMPONENTES REUTILIZÁVEIS

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.shade100,
          child: Icon(icon, color: Colors.teal.shade800),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      leading: Icon(icon, color: Colors.teal.shade700),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}
