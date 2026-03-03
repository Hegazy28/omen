// lib/features/tasks/widgets/meta_chip.dart

import 'package:flutter/material.dart';
import 'tasks_theme.dart';

class MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final bool dot;

  const MetaChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.dot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: TaskDecorations.pill(color: color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dot) ...[
            _GlowDot(color: color),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(icon, size: 9, color: color),
            const SizedBox(width: 3),
          ],
          Text(label, style: TaskTextStyles.mono(9, color: color)),
        ],
      ),
    );
  }
}

class _GlowDot extends StatelessWidget {
  final Color color;
  const _GlowDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 3)],
      ),
    );
  }
}
