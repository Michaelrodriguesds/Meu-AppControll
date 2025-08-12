import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import '../services/projeto_service.dart';
import 'configuracoes_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import 'notificacao_service.dart' removido pois não está sendo usado no código atual

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
  bool valoresOcultos = true; // Inicia oculto

  double totalInvestido = 0.0;
  int totalProjetos = 0;

  // Chave para armazenar preferência de privacidade
  static const String _prefPrivacidadeKey = 'privacidade_ativada';

  @override
  void initState() {
    super.initState();

  
    // Carrega preferências, depois os dados do usuário e projetos
    _carregarPreferencias().then((_) async {
      await carregarUsuario();
      await carregarProjetos();

      // TODO: Implemente aqui a lógica real para agendar notificações programadas
      await _agendarNotificacoesProgramadas();
    });
  }

  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      valoresOcultos = prefs.getBool(_prefPrivacidadeKey) ?? true;
    });
  }

  Future<void> _salvarPreferenciaPrivacidade(bool oculto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefPrivacidadeKey, oculto);
  }

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

  Future<void> carregarProjetos() async {
    try {
      final projetos = await ProjetoService.getProjetos(token: widget.token);
      double soma = 0.0;

      for (var projeto in projetos) {
        soma += projeto.valorAplicado;
      }

      setState(() {
        totalProjetos = projetos.length;
        totalInvestido = soma;
      });
    } catch (e) {
      // Troquei print por debugPrint para melhor prática em Flutter
      debugPrint('Erro ao carregar projetos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar projetos: $e')),
      );
    }
  }

  void mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void alternarVisibilidadeValores() {
    setState(() {
      valoresOcultos = !valoresOcultos;
    });
    _salvarPreferenciaPrivacidade(valoresOcultos);
  }

  Future<void> _atualizarTela() async {
    await Future.wait([
      carregarUsuario(),
      carregarProjetos(),
    ]);
  }

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

  /// Este método deve verificar suas datas e horários agendados,
  /// e disparar as notificações apenas nesses momentos.
  /// Aqui, estou deixando como um TODO para você implementar conforme sua lógica.
  Future<void> _agendarNotificacoesProgramadas() async {
    // TODO: Implemente aqui a lógica real para agendar notificações
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
                  child: Text(
                    'Erro ao carregar dados.\nTente novamente.',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _atualizarTela,
                  child: ListView(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Resumo Financeiro',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: Icon(
                                      valoresOcultos ? Icons.visibility_off : Icons.visibility,
                                      size: 20,
                                    ),
                                    onPressed: alternarVisibilidadeValores,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  _DashboardCard(
                                    icon: Icons.attach_money,
                                    label: 'Total Investido',
                                    value: valoresOcultos ? '•••••' : 'R\$ ${totalInvestido.toStringAsFixed(2)}',
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
                      _ActionCard(
                        icon: Icons.folder,
                        title: 'Ver Projetos',
                        subtitle: 'Visualize todos os seus projetos',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/projetos',
                          arguments: {'token': widget.token},
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.note,
                        title: 'Ver Anotações',
                        subtitle: 'Acesse suas anotações salvas',
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/anotacoes',
                          arguments: {'usuarioId': widget.usuarioId, 'token': widget.token},
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

// Widget para cartão de dashboard
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
      child: Card(
        // Ajuste para evitar uso depreciado de withOpacity
        // Usando withAlpha, alpha de 25% equivale a 64 em hexadecimal (255*0.25=~64)
        color: color.withAlpha(64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget para cartões de ação
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
