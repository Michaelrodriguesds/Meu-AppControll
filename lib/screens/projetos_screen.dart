import 'package:flutter/material.dart';
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/services/projeto_service.dart';

class ProjetosScreen extends StatefulWidget {
  final String token;

  const ProjetosScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<ProjetosScreen> createState() => _ProjetosScreenState();
}

class _ProjetosScreenState extends State<ProjetosScreen> {
  late Future<List<Projeto>> _future;

  @override
  void initState() {
    super.initState();
    _carregarProjetos();
  }

  void _carregarProjetos() {
    _future = ProjetoService.getProjetos(token: widget.token);
  }

  void _atualizarTela() {
    setState(() {
      _carregarProjetos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Meus Projetos'),
        backgroundColor: Colors.teal.shade600,
        elevation: 2,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Projeto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar projetos:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum projeto encontrado.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final projetos = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: projetos.length,
            itemBuilder: (context, index) {
              final projeto = projetos[index];
              final restante = projeto.valorNecessario - projeto.valorAplicado;
              final progresso = (projeto.progresso / 100).clamp(0.0, 1.0);
              final color = _progressoCor(progresso);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  shadowColor: Colors.black12,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    splashColor: color.withOpacity(0.2),
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
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Informações financeiras
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildInfo('Necessário', projeto.valorNecessario),
                              _buildInfo('Aplicado', projeto.valorAplicado),
                              _buildInfo('Restante', restante),
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

                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${projeto.progresso.toStringAsFixed(1)}% concluído',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Bloco com rótulo e valor formatado
  Widget _buildInfo(String label, double valor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${valor.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  /// Define a cor com base no progresso
  Color _progressoCor(double progresso) {
    if (progresso >= 0.7) return Colors.green;
    if (progresso >= 0.4) return Colors.orange;
    return Colors.red;
  }
}
