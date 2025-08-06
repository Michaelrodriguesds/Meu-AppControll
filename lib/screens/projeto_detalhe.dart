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

  /// Mostra diálogo de confirmação e realiza exclusão
  void _confirmarExclusao(BuildContext context) async {
    if (projeto.id == null || projeto.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projeto sem ID. Não é possível excluir.')),
      );
      return;
    }

    final conf = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Projeto'),
        content: const Text('Deseja realmente excluir este projeto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (conf == true) {
      try {
        await ProjetoService.deletarProjeto(projeto.id!, token);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  /// Cor dinâmica baseada no progresso
  Color _getProgressColor(double progresso) {
    if (progresso >= 0.7) return Colors.green;
    if (progresso >= 0.4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final restante = projeto.valorNecessario - projeto.valorAplicado;
    final progresso = (projeto.progresso / 100).clamp(0.0, 1.0);
    final color = _getProgressColor(progresso);

    return Scaffold(
      appBar: AppBar(
        title: Text(projeto.titulo),
        backgroundColor: Colors.teal.shade700,
      ),
      backgroundColor: const Color(0xFFF4F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📦 Cartão financeiro
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoLinha("💰 Valor necessário", projeto.valorNecessario),
                    _infoLinha("💸 Valor aplicado", projeto.valorAplicado),
                    _infoLinha("📊 Restante", restante),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${projeto.progresso.toStringAsFixed(1)}% completo',
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 📄 Informações adicionais
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTexto("🗓 Início", projeto.dataInicio.toLocal().toIso8601String().split("T")[0]),
                    _infoTexto("📂 Categoria", projeto.categoria),
                    const SizedBox(height: 12),
                    const Text(
                      "📝 Descrição",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      projeto.descricao,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ⚙ Ações
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmarExclusao(context),
                    icon: const Icon(Icons.delete),
                    label: const Text('Excluir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de linha com valores monetários
  Widget _infoLinha(String label, double valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            'R\$ ${valor.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Widget de linha com texto simples
  Widget _infoTexto(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
