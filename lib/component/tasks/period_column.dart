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
          _AccentBar(color: meta.color),
          _ColumnHeader(
            meta: meta,
            done: done,
            total: tasks.length,
            allDone: allDone,
          ),
          Expanded(
            child: tasks.isEmpty
                ? _EmptyColumn(meta: meta)
                : _TaskList(
                    tasks: tasks,
                    onToggle: (id) =>
                        ref.read(tasksProvider.notifier).toggleCompleted(id),
                    onStar: (id) =>
                        ref.read(tasksProvider.notifier).toggleStarred(id),
                    onEdit: (task) async {
                      await showDialog<void>(
                        context: context,
                        builder: (_) => _EditTaskDialog(task: task),
                      );
                    },
                    onDelete: (task) async {
                      final approved = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete task?'),
                          content: Text('Remove "${task.title}" permanently?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (approved == true) {
                        ref.read(tasksProvider.notifier).removeTask(task.id);
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

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

class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final void Function(String) onToggle;
  final void Function(String) onStar;
  final void Function(TaskModel) onEdit;
  final void Function(TaskModel) onDelete;

  const _TaskList({
    required this.tasks,
    required this.onToggle,
    required this.onStar,
    required this.onEdit,
    required this.onDelete,
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
        onEdit: () => onEdit(tasks[i]),
        onDelete: () => onDelete(tasks[i]),
      ),
    );
  }
}

class _EditTaskDialog extends ConsumerStatefulWidget {
  final TaskModel task;

  const _EditTaskDialog({required this.task});

  @override
  ConsumerState<_EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends ConsumerState<_EditTaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _notesController;
  late final TextEditingController _commentsController;
  late final TextEditingController _timeController;
  late TaskPriority _priority;
  late TaskSection _section;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _subtitleController = TextEditingController(text: widget.task.subtitle ?? '');
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _commentsController =
        TextEditingController(text: widget.task.comments.join(', '));
    _timeController = TextEditingController(text: formatTaskTime12h(widget.task.time));
    _priority = widget.task.priority;
    _section = widget.task.section;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _notesController.dispose();
    _commentsController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;

    final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
    final minute = picked.minute.toString().padLeft(2, '0');
    _timeController.text = '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _subtitleController,
                decoration: const InputDecoration(labelText: 'Subtitle (optional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _commentsController,
                decoration: const InputDecoration(
                  labelText: 'Comments (comma-separated)',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time_rounded),
                    onPressed: _pickTime,
                  ),
                ),
                onTap: _pickTime,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Priority',
                  style: TaskTextStyles.label(12, color: TaskColors.text2),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((item) {
                  return ChoiceChip(
                    selected: _priority == item,
                    label: Text(item.name),
                    onSelected: (_) => setState(() => _priority = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Section',
                  style: TaskTextStyles.label(12, color: TaskColors.text2),
                ),
              ),
              const SizedBox(height: 6),
              SegmentedButton<TaskSection>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: TaskSection.morning, label: Text('Morning')),
                  ButtonSegment(value: TaskSection.afternoon, label: Text('Afternoon')),
                  ButtonSegment(value: TaskSection.evening, label: Text('Evening')),
                ],
                selected: {_section},
                onSelectionChanged: (v) => setState(() => _section = v.first),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleController.text.trim();
            if (title.isEmpty) {
              return;
            }

            final comments = _commentsController.text
                .split(',')
                .map((entry) => entry.trim())
                .where((entry) => entry.isNotEmpty)
                .toList();

            ref.read(tasksProvider.notifier).updateTask(
                  id: widget.task.id,
                  title: title,
                  subtitle: _subtitleController.text.trim(),
                  notes: _notesController.text.trim(),
                  comments: comments,
                  time: _timeController.text.trim().isEmpty
                      ? widget.task.time
                      : _timeController.text.trim(),
                  priority: _priority,
                  section: _section,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

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
