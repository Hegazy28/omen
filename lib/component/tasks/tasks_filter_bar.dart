// lib/features/tasks/widgets/tasks_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'tasks_theme.dart';

class TasksFilterBar extends ConsumerWidget {
  const TasksFilterBar({super.key});

  static const _chips = [
    (label: 'All', filter: TaskFilter.all),
    (label: 'Active', filter: TaskFilter.active),
    (label: 'Done', filter: TaskFilter.done),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(taskFilterProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _chips.map((chip) {
        final active = current == chip.filter;
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: GestureDetector(
            onTap: () =>
                ref.read(taskFilterProvider.notifier).state = chip.filter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: active ? TaskColors.primary : TaskColors.glass,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: active ? TaskColors.primary : TaskColors.glassBorder,
                  width: 1,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: TaskColors.primary.withOpacity(0.28),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              ),
              child: Text(
                chip.label,
                style: TaskTextStyles.body(12).copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? TaskColors.skyDeep : TaskColors.text3,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
