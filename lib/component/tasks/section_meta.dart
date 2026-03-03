// lib/features/tasks/widgets/section_meta.dart
//
// Maps TaskSection enum values to their display properties.

import 'package:flutter/material.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'tasks_theme.dart';

class SectionMeta {
  final String label;
  final String timeRange;
  final IconData icon;
  final Color color;

  const SectionMeta({
    required this.label,
    required this.timeRange,
    required this.icon,
    required this.color,
  });

  static SectionMeta of(TaskSection section) => switch (section) {
        TaskSection.morning => const SectionMeta(
            label: 'Morning',
            timeRange: '06:00 – 11:59',
            icon: Icons.wb_sunny_outlined,
            color: TaskColors.morning,
          ),
        TaskSection.afternoon => const SectionMeta(
            label: 'Afternoon',
            timeRange: '12:00 – 17:59',
            icon: Icons.wb_cloudy_outlined,
            color: TaskColors.afternoon,
          ),
        TaskSection.evening => const SectionMeta(
            label: 'Evening',
            timeRange: '18:00 – 23:59',
            icon: Icons.nights_stay_outlined,
            color: TaskColors.evening,
          ),
      };
}
