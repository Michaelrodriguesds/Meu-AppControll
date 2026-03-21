import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transacao_model.dart';
import '../utils/currency_formatter.dart';

class TransacaoTile extends StatelessWidget {
  final Transacao transacao;
  const TransacaoTile({super.key, required this.transacao});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy · HH:mm').format(transacao.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              // ✅ withOpacity → withValues
              color: const Color(0xFF00897B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF00897B), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.note.isNotEmpty ? transacao.note : 'Aporte',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Text(
            '+${formatBRL(transacao.amount)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF43A047)),
          ),
        ],
      ),
    );
  }
}