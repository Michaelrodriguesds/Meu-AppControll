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
    // Cálculo do progresso
    final double progresso = (projeto.valorAplicado / projeto.investimentoNecessario).clamp(0, 1);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com botão voltar e título do projeto
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Text(
                  'Projeto: ${projeto.nome} ✈️',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48), // Espaço para equilibrar o layout
              ],
            ),
            const SizedBox(height: 8),

            // Valores financeiros
            Text('💰 Investimento Necessário: R\$ ${projeto.investimentoNecessario.toStringAsFixed(2)}'),
            Text('💸 Valor Aplicado: R\$ ${projeto.valorAplicado.toStringAsFixed(2)}'),
            Text('📊 Investimento Restante: R\$ ${(projeto.investimentoNecessario - projeto.valorAplicado).toStringAsFixed(2)}'),

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
            Text('🗓️ Início: ${projeto.dataInicio}'),
            Text('📂 Categoria: ${projeto.categoria}'),
            const SizedBox(height: 12),

            // Descrição
            const Text('📝 Descrição:'),
            Text(projeto.descricao),

            const SizedBox(height: 16),

            // Botões ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onEditar,
                  child: const Text('Editar Projeto'),
                ),
                ElevatedButton(
                  onPressed: onDeletar,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Deletar Projeto'),
                ),
                ElevatedButton(
                  onPressed: onInvestirMais,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Investi Mais'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
