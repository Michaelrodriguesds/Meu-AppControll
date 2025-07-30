import 'package:flutter/material.dart';
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/services/projeto_service.dart';

class ProjetoDetalheScreen extends StatelessWidget {
  final Projeto projeto;
  final String token;

  const ProjetoDetalheScreen({
    Key? key,
    required this.projeto,
    required this.token,
  }) : super(key: key);

  void _confirmarExclusao(BuildContext context) async {
    if (projeto.id == null || projeto.id!.isEmpty) {
      // 🐞 ID ausente
      print('❌ Projeto sem ID: ${projeto.toJson()}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto sem ID. Não é possível excluir.')),
      );
      return;
    }

    final conf = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text('Deseja realmente excluir?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    );

    if (conf == true) {
      try {
        await ProjetoService.deletarProjeto(projeto.id!, token);
        Navigator.pop(context, true); // Volta para lista com sucesso
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restante = projeto.valorNecessario - projeto.valorAplicado;

    return Scaffold(
      appBar: AppBar(title: Text('Projeto: ${projeto.titulo}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('💰 Necessário: R\$ ${projeto.valorNecessario.toStringAsFixed(2)}'),
            Text('💸 Aplicado: R\$ ${projeto.valorAplicado.toStringAsFixed(2)}'),
            Text('📊 Restante: R\$ ${restante.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: (projeto.progresso / 100).clamp(0.0, 1.0)),
            Text('${projeto.progresso.toStringAsFixed(1)}% completo'),
            const SizedBox(height: 16),
            Text('🗓 Início: ${projeto.dataInicio.toLocal().toIso8601String().split("T")[0]}'),
            Text('📂 Categoria: ${projeto.categoria}'),
            const SizedBox(height: 16),
            const Text('📝 Descrição:'),
            Text(projeto.descricao),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/projeto_form',
                      arguments: {
                        'projeto': projeto,
                        'token': token,
                        'usuarioId': projeto.usuarioId,
                      },
                    ).then((ret) {
                      if (ret == true) Navigator.pop(context, true);
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _confirmarExclusao(context),
                  icon: const Icon(Icons.delete),
                  label: const Text('Excluir'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
