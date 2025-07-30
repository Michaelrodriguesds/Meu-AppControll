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
    return Scaffold(
      appBar: AppBar(title: const Text('Projetos')),
      body: FutureBuilder<List<Projeto>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum projeto encontrado.'));
          }

          final projetos = snapshot.data!;

          return ListView.builder(
            itemCount: projetos.length,
            itemBuilder: (context, index) {
              final projeto = projetos[index];
              final restante = projeto.valorNecessario - projeto.valorAplicado;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        projeto.titulo,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Necessário: R\$ ${projeto.valorNecessario.toStringAsFixed(2)}'),
                      Text('Aplicado: R\$ ${projeto.valorAplicado.toStringAsFixed(2)}'),
                      Text('Restante: R\$ ${restante.toStringAsFixed(2)}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (projeto.progresso / 100).clamp(0.0, 1.0),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              '/projeto_detalhe',
                              arguments: {
                                'projeto': projeto,
                                'token': widget.token,
                              },
                            );
                            _atualizarTela(); // Atualiza após retornar da tela de detalhe
                          },
                          child: const Text('Ver Detalhes'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
