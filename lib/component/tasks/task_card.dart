// lib/features/tasks/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omen/component/tasks/task_model.dart';
import 'tasks_theme.dart';
import 'meta_chip.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onStar;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onStar,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.task.isCompleted ? 1.0 : 0.0,
    );
    _checkScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _handleToggle() {
    HapticFeedback.lightImpact();
    widget.onToggle();
    widget.task.isCompleted ? _checkCtrl.reverse() : _checkCtrl.forward();
  }

  Color get _priorityColor => switch (widget.task.priority) {
        TaskPriority.high => TaskColors.priorityHigh,
        TaskPriority.medium => TaskColors.priorityMed,
        TaskPriority.low => TaskColors.priorityLow,
      };

  String get _priorityLabel => switch (widget.task.priority) {
        TaskPriority.high => 'High',
        TaskPriority.medium => 'Med',
        TaskPriority.low => 'Low',
      };

  @override
  Widget build(BuildContext context) {
    final completed = widget.task.isCompleted;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: AnimatedOpacity(
          opacity: completed ? 0.45 : 1.0,
          duration: const Duration(milliseconds: 280),
          child: Container(
            decoration: BoxDecoration(
              color: TaskColors.glass,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: TaskColors.glassBorder.withOpacity(completed ? 0.5 : 1),
                width: 1,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Priority accent bar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    width: 3,
                    decoration: BoxDecoration(
                      color: completed
                          ? _priorityColor.withOpacity(0.25)
                          : _priorityColor,
                      boxShadow: completed
                          ? null
                          : [
                              BoxShadow(
                                  color: _priorityColor.withOpacity(0.5),
                                  blurRadius: 5)
                            ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 11, 10, 11),
                      child: Row(
                        children: [
                          // Checkbox
                          GestureDetector(
                            onTap: _handleToggle,
                            child: ScaleTransition(
                              scale: _checkScale,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 220),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: completed
                                      ? TaskColors.success
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: completed
                                        ? TaskColors.success
                                        : TaskColors.glassBorder,
                                    width: 1.5,
                                  ),
                                  boxShadow: completed
                                      ? [
                                          BoxShadow(
                                            color: TaskColors.success
                                                .withOpacity(0.4),
                                            blurRadius: 7,
                                          )
                                        ]
                                      : null,
                                ),
                                child: completed
                                    ? const Icon(
                                        Icons.check_rounded,
                                        size: 12,
                                        color: TaskColors.skyDeep,
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          // Title + subtitle + meta
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 220),
                                  style: TaskTextStyles.label(13).copyWith(
                                    color: completed
                                        ? TaskColors.text3
                                        : TaskColors.text1,
                                    decoration: completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: TaskColors.text3,
                                  ),
                                  child: Text(
                                    widget.task.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.task.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.task.subtitle!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TaskTextStyles.body(11,
                                        color: TaskColors.text3),
                                  ),
                                ],
                                if (widget.task.notes != null && widget.task.notes!.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.task.notes!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TaskTextStyles.body(10,
                                        color: TaskColors.text2),
                                  ),
                                ],
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    MetaChip(
                                      label: formatTaskTime12h(widget.task.time),
                                      color: TaskColors.primary,
                                      icon: Icons.access_time_rounded,
                                    ),
                                    const SizedBox(width: 5),
                                    MetaChip(
                                      label: _priorityLabel,
                                      color: _priorityColor,
                                      dot: true,
                                    ),
                                    if (widget.task.comments.isNotEmpty) ...[
                                      const SizedBox(width: 5),
                                      MetaChip(
                                        label: '${widget.task.comments.length} comment${widget.task.comments.length > 1 ? 's' : ''}',
                                        color: TaskColors.text3,
                                        icon: Icons.chat_bubble_outline_rounded,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),

                          if (widget.onEdit != null || widget.onDelete != null)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              icon: const Icon(
                                Icons.more_horiz_rounded,
                                color: TaskColors.text3,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  widget.onEdit?.call();
                                } else if (value == 'delete') {
                                  widget.onDelete?.call();
                                }
                              },
                              itemBuilder: (_) => [
                                if (widget.onEdit != null)
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit task'),
                                  ),
                                if (widget.onDelete != null)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete task'),
                                  ),
                              ],
                            ),

                          // Star
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.onStar();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  widget.task.isStarred
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  key: ValueKey(widget.task.isStarred),
                                  size: 17,
                                  color: widget.task.isStarred
                                      ? TaskColors.morning
                                      : TaskColors.text3,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
