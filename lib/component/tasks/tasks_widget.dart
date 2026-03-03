// lib/features/tasks/widgets/tasks_widget.dart
//
// DROP-IN USAGE:
//
//   import 'package:your_app/features/tasks/tasks.dart';
//
//   // Inside any widget tree (must be inside a ProviderScope):
//   const TasksWidget()
//
// The widget fills its parent. Wrap it in a SizedBox or Expanded
// to control its bounds within your layout.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'tasks_theme.dart';
import 'tasks_progress_bar.dart';
import 'tasks_filter_bar.dart';
import 'period_column.dart';

class TasksWidget extends ConsumerWidget {
  const TasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(groupedTasksProvider);
    final progress = ref.watch(taskProgressProvider);
    final allTasks = ref.watch(tasksProvider);
    final completed = allTasks.where((t) => t.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top bar ──────────────────────────────────
        _TopBar(
          completedCount: completed,
          totalCount: allTasks.length,
        ),
        const SizedBox(height: 16),

        // ── Progress bar ─────────────────────────────
        TasksProgressBar(
          progress: progress,
          completed: completed,
          total: allTasks.length,
        ),
        const SizedBox(height: 16),

        // ── 3 period columns ─────────────────────────
        Expanded(
          child: _ColumnsRow(grouped: grouped),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const _TopBar({
    required this.completedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Title
        Text('My Tasks', style: TaskTextStyles.heading(22)),
        const SizedBox(width: 12),
        Text(
          '$completedCount / $totalCount',
          style: TaskTextStyles.mono(13, color: TaskColors.text3),
        ),

        const Spacer(),

        // Filter chips
        const TasksFilterBar(),
        const SizedBox(width: 12),

        // Add button
        _AddButton(),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // TODO: wire up your add-task flow here
      },
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [TaskColors.primaryGlow, TaskColors.primary],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: TaskColors.primary.withOpacity(0.30),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 17, color: TaskColors.skyDeep),
            const SizedBox(width: 5),
            Text(
              'Add Task',
              style: TaskTextStyles.body(13).copyWith(
                fontWeight: FontWeight.w700,
                color: TaskColors.skyDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Three-column row ──────────────────────────────────────

class _ColumnsRow extends StatelessWidget {
  final Map<TaskSection, List<TaskModel>> grouped;

  const _ColumnsRow({required this.grouped});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: TaskSection.values.map((section) {
        final tasks = grouped[section] ?? [];
        return Expanded(
          child: Padding(
            // gap between columns
            padding: EdgeInsets.only(
              right: section != TaskSection.values.last ? 14 : 0,
            ),
            child: PeriodColumn(
              section: section,
              tasks: tasks,
            ),
          ),
        );
      }).toList(),
    );
  }
}
