import 'package:flutter/material.dart';
import '../models/anotacao_model.dart';

class AnotacaoCard extends StatelessWidget {
  final AnotacaoModel anotacao;
  final VoidCallback onEditar;
  final VoidCallback onDeletar;

  const AnotacaoCard({
    Key? key,
    required this.anotacao,
    required this.onEditar,
    required this.onDeletar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Text(
              anotacao.titulo,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Conteúdo
            Text(
              anotacao.conteudo,
              style: TextStyle(fontSize: 16),
            ),

            // Data de lembrete (se existir)
            if (anotacao.dataLembrete != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Icon(Icons.alarm, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Lembrete: ${anotacao.dataLembrete!.day.toString().padLeft(2, '0')}/'
                      '${anotacao.dataLembrete!.month.toString().padLeft(2, '0')}/'
                      '${anotacao.dataLembrete!.year}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            // Botões
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEditar,
                  child: Text('Editar'),
                ),
                TextButton(
                  onPressed: onDeletar,
                  child: Text('Excluir', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
