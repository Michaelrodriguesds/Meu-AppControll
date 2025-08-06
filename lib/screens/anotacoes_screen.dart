import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';

class AnotacoesScreen extends StatefulWidget {
  final String usuarioId;
  final String token;

  const AnotacoesScreen({
    Key? key,
    required this.usuarioId,
    required this.token,
  }) : super(key: key);

  @override
  State<AnotacoesScreen> createState() => _AnotacoesScreenState();
}

class _AnotacoesScreenState extends State<AnotacoesScreen> {
  late Future<List<Anotacao>> _future;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  // Carrega a lista de anotações do serviço
  void _carregar() {
    _future = AnotacaoService.listar(widget.token);
  }

  // Atualiza a tela após ações
  void _atualizarTela() {
    setState(() => _carregar());
  }

  // Confirmação de exclusão de anotação
  void _confirmarExclusao(Anotacao a) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Anotação'),
        content: const Text('Tem certeza que deseja excluir esta anotação?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        await AnotacaoService.deletar(a.id!, widget.token);
        _atualizarTela();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Minhas Anotações"),
        centerTitle: true,
        backgroundColor: Colors.teal.shade700,
      ),
      body: FutureBuilder<List<Anotacao>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final anotacoes = snapshot.data ?? [];

          if (anotacoes.isEmpty) {
            return const Center(child: Text('Nenhuma anotação encontrada.'));
          }

          // Lista estilizada com Cards
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: anotacoes.length,
            itemBuilder: (context, index) {
              final a = anotacoes[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    a.titulo ?? 'Sem título',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      a.conteudo ?? '',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'editar') {
                        Navigator.pushNamed(
                          context,
                          '/anotacao_form',
                          arguments: {
                            'anotacao': a,
                            'usuarioId': widget.usuarioId,
                            'token': widget.token,
                          },
                        ).then((_) => _atualizarTela());
                      } else if (value == 'excluir') {
                        _confirmarExclusao(a);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'editar', child: Text('Editar')),
                      const PopupMenuItem(value: 'excluir', child: Text('Excluir')),
                    ],
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Botão flutuante com estilo moderno
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/anotacao_form',
            arguments: {
              'usuarioId': widget.usuarioId,
              'token': widget.token,
            },
          );
          _atualizarTela();
        },
        label: const Text('Nova Anotação'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
