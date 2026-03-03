// lib/features/tasks/widgets/period_column.dart
//
// A single day-period column (Morning / Afternoon / Evening).
// Renders a header + independent scrollable list of TaskCards.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'package:omen/component/tasks/tasks_provider.dart';
import 'tasks_theme.dart';
import 'section_meta.dart';
import 'task_card.dart';

class PeriodColumn extends ConsumerWidget {
  final TaskSection section;
  final List<TaskModel> tasks;

  const PeriodColumn({
    super.key,
    required this.section,
    required this.tasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = SectionMeta.of(section);
    final done = tasks.where((t) => t.isCompleted).length;
    final allDone = tasks.isNotEmpty && done == tasks.length;

    return Container(
      decoration: TaskDecorations.glassCard(),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top accent bar
          _AccentBar(color: meta.color),

          // Column header
          _ColumnHeader(
            meta: meta,
            done: done,
            total: tasks.length,
            allDone: allDone,
          ),

          // Scrollable task list
          Expanded(
            child: tasks.isEmpty
                ? _EmptyColumn(meta: meta)
                : _TaskList(
                    tasks: tasks,
                    onToggle: (id) =>
                        ref.read(tasksProvider.notifier).toggleCompleted(id),
                    onStar: (id) =>
                        ref.read(tasksProvider.notifier).toggleStarred(id),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Accent bar ────────────────────────────────────────────

class _AccentBar extends StatelessWidget {
  final Color color;
  const _AccentBar({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.3),
            Colors.transparent
          ],
        ),
      ),
    );
  }
}

// ── Column header ─────────────────────────────────────────

class _ColumnHeader extends StatelessWidget {
  final SectionMeta meta;
  final int done;
  final int total;
  final bool allDone;

  const _ColumnHeader({
    required this.meta,
    required this.done,
    required this.total,
    required this.allDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: TaskColors.glassBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: meta.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: meta.color.withOpacity(0.25), width: 1),
            ),
            child: Icon(meta.icon, size: 17, color: meta.color),
          ),
          const SizedBox(width: 10),

          // Label + time range
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meta.label,
                    style: TaskTextStyles.label(15, color: TaskColors.text1)),
                const SizedBox(height: 1),
                Text(meta.timeRange,
                    style: TaskTextStyles.mono(10,
                        color: TaskColors.text3, weight: FontWeight.w400)),
              ],
            ),
          ),

          // Done badge
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: allDone
                  ? TaskColors.success.withOpacity(0.12)
                  : TaskColors.glass,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: allDone
                    ? TaskColors.success.withOpacity(0.35)
                    : TaskColors.glassBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (allDone) ...[
                  Icon(Icons.check_circle_rounded,
                      size: 10, color: TaskColors.success),
                  const SizedBox(width: 4),
                ],
                Text(
                  '$done/$total',
                  style: TaskTextStyles.mono(11,
                      color: allDone ? TaskColors.success : TaskColors.text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Scrollable task list ──────────────────────────────────

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final void Function(String) onToggle;
  final void Function(String) onStar;

  const _TaskList({
    required this.tasks,
    required this.onToggle,
    required this.onStar,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => TaskCard(
        task: tasks[i],
        onToggle: () => onToggle(tasks[i].id),
        onStar: () => onStar(tasks[i].id),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────

class _EmptyColumn extends StatelessWidget {
  final SectionMeta meta;
  const _EmptyColumn({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 28, color: meta.color.withOpacity(0.25)),
          const SizedBox(height: 10),
          Text('No tasks',
              style: TaskTextStyles.body(12, color: TaskColors.text3)),
        ],
      ),
    );
  }
}
