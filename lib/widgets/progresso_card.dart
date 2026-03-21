import 'package:flutter/material.dart';

class ProgressoCard extends StatelessWidget {
  final double progress;
  final Color  color;
  final bool   showLabel;

  const ProgressoCard({
    super.key,
    required this.progress,
    this.color     = const Color(0xFF00897B),
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = (progress / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            // ✅ unnecessary_underscores: (_, __, child) → (_, child)
            builder: (_, value, child) => LinearProgressIndicator(
              value:           value,
              minHeight:       10,
              backgroundColor: Colors.grey.shade200,
              valueColor:      AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            '${progress.toStringAsFixed(1)}% concluído',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ],
    );
  }
}