import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';

class ValorChip extends StatelessWidget {
  final double value;
  final bool   selected;
  final VoidCallback onTap;

  const ValorChip({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00897B) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFF00897B) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          formatBRL(value),
          style: TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w700,
            color:      selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}