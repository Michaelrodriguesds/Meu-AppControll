import 'package:flutter/material.dart';
import 'package:meu_app_financas/models/projeto_model.dart';
import 'package:meu_app_financas/services/projeto_service.dart';

/// Tela que exibe detalhes completos de um projeto
class ProjetoDetalheScreen extends StatelessWidget {
  final Projeto projeto;
  final String token;

  const ProjetoDetalheScreen({
    Key? key,
    required this.projeto,
    required this.token,
  }) : super(key: key);

  /// Diálogo de confirmação para exclusão
  void _confirmarExclusao(BuildContext context) async {
    if (projeto.id == null || projeto.id!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projeto sem ID válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final conf = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Projeto', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Deseja realmente excluir este projeto? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (conf == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Excluindo projeto...'),
          duration: Duration(seconds: 2),
        ),
      );

      final resultado = await ProjetoService.deletarProjeto(projeto.id!, token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['message']),
          backgroundColor: resultado['success'] ? Colors.green : Colors.red,
        ),
      );

      if (resultado['success']) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Cor do progresso baseada em porcentagem
  Color _getProgressColor(double progresso) {
    if (progresso >= 1.0) return Colors.green.shade700;
    if (progresso >= 0.7) return Colors.green;
    if (progresso >= 0.4) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    // Removida a variável 'theme' não utilizada
    final restante = projeto.valorNecessario - projeto.valorAplicado;
    final progresso = (projeto.progresso / 100).clamp(0.0, 1.0);
    final color = _getProgressColor(progresso);

    return Scaffold(
      appBar: AppBar(
        title: Text(projeto.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade700,
        elevation: 2,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Resumo Financeiro
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Título do card
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'RESUMO FINANCEIRO',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Informações financeiras
                    _buildFinanceInfoRow(
                      icon: Icons.flag_outlined,
                      label: 'VALOR NECESSÁRIO',
                      value: projeto.valorNecessario,
                      color: Colors.teal,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildFinanceInfoRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'VALOR APLICADO',
                      value: projeto.valorAplicado,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    
                    _buildFinanceInfoRow(
                      icon: Icons.trending_up_outlined,
                      label: 'VALOR RESTANTE',
                      value: restante,
                      color: color,
                    ),
                    const SizedBox(height: 16),
                    
                    // Barra de progresso
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Porcentagem de conclusão
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${projeto.progresso.toStringAsFixed(1)}% CONCLUÍDO',
                        style: TextStyle(
                          fontSize: 13,
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card de Informações do Projeto
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título do card
                    const Text(
                      'INFORMAÇÕES DO PROJETO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Data de início
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'DATA DE INÍCIO',
                      value: '${projeto.dataInicio.day}/${projeto.dataInicio.month}/${projeto.dataInicio.year}',
                    ),
                    const SizedBox(height: 12),
                    
                    // Categoria
                    _buildDetailRow(
                      icon: Icons.category_outlined,
                      label: 'CATEGORIA',
                      value: projeto.categoria,
                    ),
                    const SizedBox(height: 16),
                    
                    // Descrição
                    const Text(
                      'DESCRIÇÃO',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      projeto.descricao.isNotEmpty 
                          ? projeto.descricao 
                          : 'Nenhuma descrição fornecida',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Botões de ação
            Row(
              children: [
                // Botão Editar
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
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text(
                      'EDITAR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Botão Excluir
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmarExclusao(context),
                    icon: const Icon(Icons.delete, size: 20),
                    label: const Text(
                      'EXCLUIR',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  /// Widget para linha de informação financeira
  Widget _buildFinanceInfoRow({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24, color: color.withOpacity(0.8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'R\$ ${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Widget para linha de detalhe do projeto
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Colors.teal.withOpacity(0.8)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}