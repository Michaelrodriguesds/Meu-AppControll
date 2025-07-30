import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';
import '../services/anotacao_service.dart';

class AnotacoesScreen extends StatefulWidget {
  final String usuarioId;
  final String token;

  const AnotacoesScreen({Key? key, required this.usuarioId, required this.token}) : super(key: key);

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

  void _carregar() {
    _future = AnotacaoService.listar(widget.token);
  }

  void _atualizarTela() {
    setState(() => _carregar());
  }

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
      appBar: AppBar(title: const Text("Minhas Anotações")),
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

          return ListView.builder(
            itemCount: anotacoes.length,
            itemBuilder: (context, index) {
              final a = anotacoes[index];

              return ListTile(
                title: Text(a.titulo ?? 'Sem título'),
                subtitle: Text(a.conteudo ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.pushNamed(
                          context,
                          '/anotacao_form',
                          arguments: {
                            'anotacao': a,
                            'usuarioId': widget.usuarioId,
                            'token': widget.token,
                          },
                        );
                        _atualizarTela();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmarExclusao(a),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
