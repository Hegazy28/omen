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
        _TopBar(
          completedCount: completed,
          totalCount: allTasks.length,
        ),
        const SizedBox(height: 12),
        const _SmartControls(),
        const SizedBox(height: 12),
        TasksProgressBar(
          progress: progress,
          completed: completed,
          total: allTasks.length,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _ColumnsRow(grouped: grouped),
        ),
      ],
    );
  }
}

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
        Text('My Tasks', style: TaskTextStyles.heading(22)),
        const SizedBox(width: 12),
        Text(
          '$completedCount / $totalCount',
          style: TaskTextStyles.mono(13, color: TaskColors.text3),
        ),
        const Spacer(),
        const TasksFilterBar(),
        const SizedBox(width: 12),
        const _AddButton(),
      ],
    );
  }
}

class _SmartControls extends ConsumerStatefulWidget {
  const _SmartControls();

  @override
  ConsumerState<_SmartControls> createState() => _SmartControlsState();
}

class _SmartControlsState extends ConsumerState<_SmartControls> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController =
        TextEditingController(text: ref.read(taskSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedPriority = ref.watch(taskPriorityFilterProvider);
    final selectedSection = ref.watch(taskSectionFocusProvider);
    final hasFilters =
        _searchController.text.trim().isNotEmpty ||
        selectedPriority != null ||
        selectedSection != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: TaskDecorations.glassCard(radius: BorderRadius.circular(14)),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              controller: _searchController,
              onChanged: (value) =>
                  ref.read(taskSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search task or subtitle',
                hintStyle: TaskTextStyles.body(11, color: TaskColors.text3),
                isDense: true,
                filled: true,
                fillColor: Colors.white.withOpacity(0.04),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 18, color: TaskColors.text3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: TaskColors.glassBorder.withOpacity(0.9)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _QuickMenu<TaskPriority>(
            label: 'Priority',
            current: selectedPriority,
            items: TaskPriority.values,
            itemLabel: (priority) => priority.name,
            onSelected: (value) =>
                ref.read(taskPriorityFilterProvider.notifier).state = value,
          ),
          const SizedBox(width: 8),
          _QuickMenu<TaskSection>(
            label: 'Section',
            current: selectedSection,
            items: TaskSection.values,
            itemLabel: (section) => section.name,
            onSelected: (value) =>
                ref.read(taskSectionFocusProvider.notifier).state = value,
          ),
          const Spacer(),
          if (hasFilters)
            TextButton.icon(
              onPressed: () {
                _searchController.clear();
                ref.read(taskSearchQueryProvider.notifier).state = '';
                ref.read(taskPriorityFilterProvider.notifier).state = null;
                ref.read(taskSectionFocusProvider.notifier).state = null;
              },
              icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
              label: Text('Clear', style: TaskTextStyles.label(12)),
            ),
        ],
      ),
    );
  }
}

class _QuickMenu<T> extends StatelessWidget {
  final String label;
  final T? current;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onSelected;

  const _QuickMenu({
    required this.label,
    required this.current,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onSelected,
      itemBuilder: (_) => [
        const PopupMenuItem<T?>(
          value: null,
          child: Text('All'),
        ),
        ...items.map(
          (item) => PopupMenuItem<T?>(
            value: item,
            child: Text(itemLabel(item)),
          ),
        ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.04),
          border: Border.all(color: TaskColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              current == null ? label : '${label}: ${itemLabel(current as T)}',
              style: TaskTextStyles.body(11,
                  color: current == null ? TaskColors.text3 : TaskColors.text1),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded,
                size: 16, color: TaskColors.text3),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.lightImpact();
        await showDialog<void>(
          context: context,
          builder: (_) => const _AddTaskDialog(),
        );
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

class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog();

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _timeController = TextEditingController(text: '09:00 AM');
  TaskPriority _priority = TaskPriority.medium;
  TaskSection _section = TaskSection.morning;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
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
      title: const Text('Add Task'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _subtitleController,
                decoration:
                    const InputDecoration(labelText: 'Subtitle (optional)'),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _timeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Time (hh:mm AM/PM)',
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
                child: Text('Priority', style: TaskTextStyles.label(12)),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((item) {
                  final isSelected = _priority == item;
                  return ChoiceChip(
                    selected: isSelected,
                    label: Text(item.name),
                    onSelected: (_) => setState(() => _priority = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Section', style: TaskTextStyles.label(12)),
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
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TaskColors.glassBorder),
                ),
                child: Text(
                  'Preview: ${_titleController.text.trim().isEmpty ? 'New task' : _titleController.text.trim()} • ${_timeController.text} • ${_section.name} • ${_priority.name}',
                  style: TaskTextStyles.body(11, color: TaskColors.text2),
                ),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Title is required')),
              );
              return;
            }

            ref.read(tasksProvider.notifier).addTask(
                  title: title,
                  subtitle: _subtitleController.text.trim(),
                  time: _timeController.text.trim().isEmpty
                      ? '09:00 AM'
                      : _timeController.text.trim(),
                  priority: _priority,
                  section: _section,
                );
            Navigator.of(context).pop();
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

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
