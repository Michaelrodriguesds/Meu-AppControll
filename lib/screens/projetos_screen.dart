import 'package:flutter/material.dart';
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/services/projeto_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjetosScreen extends StatefulWidget {
  final String token;

  const ProjetosScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  late Future<List<Projeto>> _future;
  bool valoresOcultos = true; // Estado para controle de privacidade
  final String _prefPrivacidadeKey = 'projetos_privacidade_ativada';

  @override
  void initState() {
    super.initState();
    _carregarPreferencias().then((_) {
      _carregarProjetos();
    });
  }

  // Carrega as preferências de privacidade
  Future<void> _carregarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      valoresOcultos = prefs.getBool(_prefPrivacidadeKey) ?? true;
    });
  }

  // Salva o estado da privacidade
  Future<void> _salvarPreferenciaPrivacidade(bool oculto) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefPrivacidadeKey, oculto);
  }

  /// Carrega os projetos do usuário
  void _carregarProjetos() {
    _future = ProjetoService.getProjetos(token: widget.token);
  }

  /// Atualiza a lista de projetos
  Future<void> _atualizarTela() async {
    setState(() {
      _carregarProjetos();
    });
  }

  // Alterna visibilidade dos valores
  void alternarVisibilidadeValores() {
    setState(() {
      valoresOcultos = !valoresOcultos;
    });
    _salvarPreferenciaPrivacidade(valoresOcultos);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Meus Projetos', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: Colors.teal.shade600,
        elevation: 2,
        centerTitle: true,
        actions: [
          // Botão de privacidade (substitui o de refresh)
          IconButton(
            icon: Icon(
              valoresOcultos ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            onPressed: alternarVisibilidadeValores,
            tooltip: valoresOcultos ? 'Mostrar valores' : 'Ocultar valores',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _atualizarTela,
        child: FutureBuilder<List<Projeto>>(
          future: _future,
          builder: (context, snapshot) {
            // Tratamento de estados
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar projetos',
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _atualizarTela,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum projeto encontrado',
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque no botão + para criar seu primeiro projeto!',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            }

            final projetos = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: projetos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final projeto = projetos[index];
                final progresso = (projeto.progresso / 100).clamp(0.0, 1.0);
                final isCompleto = progresso >= 1.0;
                final color = _progressoCor(progresso);

                return _ProjetoCard(
                  projeto: projeto,
                  color: color,
                  isCompleto: isCompleto,
                  valoresOcultos: valoresOcultos,
                  onTap: () async {
                    await Navigator.pushNamed(
                      context,
                      '/projeto_detalhe',
                      arguments: {
                        'projeto': projeto,
                        'token': widget.token,
                      },
                    );
                    _atualizarTela();
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/projeto_form',
          arguments: {'token': widget.token},
        ).then((_) => _atualizarTela()),
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  /// Define a cor com base no progresso
  Color _progressoCor(double progresso) {
    if (progresso >= 1.0) return Colors.green.shade700;
    if (progresso >= 0.7) return Colors.green;
    if (progresso >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

/// Widget personalizado para cada card de projeto
class _ProjetoCard extends StatelessWidget {
  final Projeto projeto;
  final Color color;
  final bool isCompleto;
  final bool valoresOcultos;
  final VoidCallback onTap;

  const _ProjetoCard({
    required this.projeto,
    required this.color,
    required this.isCompleto,
    required this.valoresOcultos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final restante = projeto.valorNecessario - projeto.valorAplicado;
    final progresso = (projeto.progresso / 100).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isCompleto 
              ? BorderSide(color: color.withOpacity(0.5), width: 2) 
              : BorderSide.none,
        ),
        color: isCompleto ? color.withOpacity(0.05) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          splashColor: color.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho com avatar e título
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withOpacity(0.8),
                      child: Text(
                        projeto.titulo[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        projeto.titulo,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isCompleto ? color : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Badge de completo
                    if (isCompleto)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('✅', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'Completo',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informações financeiras com destaque
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoItem(
                      label: 'NECESSÁRIO',
                      value: projeto.valorNecessario,
                      icon: Icons.flag_outlined,
                      valoresOcultos: valoresOcultos,
                    ),
                    _InfoItem(
                      label: 'APLICADO',
                      value: projeto.valorAplicado,
                      icon: Icons.account_balance_wallet_outlined,
                      valoresOcultos: valoresOcultos,
                    ),
                    _InfoItem(
                      label: 'RESTANTE',
                      value: restante,
                      icon: Icons.trending_up_outlined,
                      valoresOcultos: valoresOcultos,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Barra de progresso
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progresso,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),

                const SizedBox(height: 8),

                // Rodapé com progresso e data
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${projeto.progresso.toStringAsFixed(1)}% concluído',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'INÍCIO: ${projeto.dataInicio.day}/${projeto.dataInicio.month}/${projeto.dataInicio.year}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para exibir informações financeiras formatadas com destaque
class _InfoItem extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final bool valoresOcultos;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.valoresOcultos,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12, 
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          valoresOcultos ? '•••••' : 'R\$ ${value.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}