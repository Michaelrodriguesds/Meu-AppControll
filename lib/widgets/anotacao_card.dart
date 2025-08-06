import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';

class AnotacaoCard extends StatelessWidget {
  final Anotacao anotacao; // 🔄 Nome da classe corrigido
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const AnotacaoCard({
    super.key,
    required this.anotacao,
    required this.onEditar,
    required this.onDeletar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anotacao.titulo ?? 'Sem título',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(anotacao.conteudo ?? 'Sem conteúdo'),
            if (anotacao.data != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.alarm, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    'Lembrete: ${anotacao.data!.day.toString().padLeft(2, '0')}/'
                    '${anotacao.data!.month.toString().padLeft(2, '0')}/'
                    '${anotacao.data!.year}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onEditar, child: const Text('Editar')),
                TextButton(
                  onPressed: onDeletar,
                  child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
