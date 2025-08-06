import 'package:flutter/material.dart';
import '../models/projeto_model.dart';

class ProjetoCard extends StatelessWidget {
  final Projeto projeto;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;
  final VoidCallback onInvestirMais;

  const ProjetoCard({
    super.key,
    required this.projeto,
    required this.onEditar,
    required this.onDeletar,
    required this.onInvestirMais,
  });

  @override
  Widget build(BuildContext context) {
    final double progresso =
        (projeto.valorAplicado / projeto.valorNecessario).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título com botão voltar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    'Projeto: ${projeto.titulo} ✈️',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
            const SizedBox(height: 8),

            // Valores financeiros
            Text('💰 Investimento Necessário: R\$ ${projeto.valorNecessario.toStringAsFixed(2)}'),
            Text('💸 Valor Aplicado: R\$ ${projeto.valorAplicado.toStringAsFixed(2)}'),
            Text('📊 Investimento Restante: R\$ ${(projeto.valorNecessario - projeto.valorAplicado).toStringAsFixed(2)}'),

            const SizedBox(height: 12),

            // Progresso
            const Text('📈 Progresso:'),
            LinearProgressIndicator(
              value: progresso,
              minHeight: 12,
              backgroundColor: Colors.grey[300],
              color: Colors.blue,
            ),
            const SizedBox(height: 4),
            Text('${(progresso * 100).toStringAsFixed(0)}%'),

            const SizedBox(height: 12),

            // Informações adicionais
            Text('🗓️ Início: ${projeto.dataInicio.toLocal().toString().split(' ')[0]}'),
            Text('📂 Categoria: ${projeto.categoria}'),

            const SizedBox(height: 12),

            // Descrição
            const Text('📝 Descrição:'),
            Text(projeto.descricao),

            const SizedBox(height: 16),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: onEditar, child: const Text('Editar')),
                ElevatedButton(
                  onPressed: onDeletar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Deletar'),
                ),
                ElevatedButton(
                  onPressed: onInvestirMais,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Investir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
