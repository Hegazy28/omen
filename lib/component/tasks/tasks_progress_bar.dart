// lib/features/tasks/widgets/tasks_progress_bar.dart

import 'package:flutter/material.dart';
import 'tasks_theme.dart';

class TasksProgressBar extends StatelessWidget {
  final double progress; // 0.0 – 1.0
  final int completed;
  final int total;

  const TasksProgressBar({
    super.key,
    required this.progress,
    required this.completed,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '${(progress * 100).toInt()}%',
          style: TaskTextStyles.mono(11, color: TaskColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Stack(
              children: [
                Container(height: 3, color: TaskColors.glass),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          TaskColors.primaryGlow,
                          TaskColors.primary,
                          TaskColors.success,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: TaskColors.primary.withOpacity(0.5),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$completed of $total completed',
          style: TaskTextStyles.body(12, color: TaskColors.text3),
        ),
      ],
    );
  }
}
