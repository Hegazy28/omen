// lib/features/tasks/data/tasks_sample_data.dart
//
// Replace this list with your real data source later.
// The provider imports from here — you only need to change this file.

import 'package:omen/component/tasks/task_model.dart';

const List<TaskModel> kSampleTasks = [
  // ── Morning ─────────────────────────────────────────
  TaskModel(
    id: '1',
    title: 'Review design mockups',
    subtitle: 'Stitch export',
    time: '08:30',
    priority: TaskPriority.high,
    section: TaskSection.morning,
  ),
  TaskModel(
    id: '2',
    title: 'Morning run',
    subtitle: '5km — riverside route',
    time: '07:00',
    priority: TaskPriority.low,
    section: TaskSection.morning,
    isCompleted: true,
  ),
  TaskModel(
    id: '3',
    title: 'Team standup call',
    subtitle: 'Engineering sync',
    time: '10:00',
    priority: TaskPriority.high,
    section: TaskSection.morning,
    isCompleted: true,
  ),
  TaskModel(
    id: '9',
    title: 'Stretch & meditate',
    subtitle: '15 min session',
    time: '06:30',
    priority: TaskPriority.low,
    section: TaskSection.morning,
    isStarred: true,
  ),

  // ── Afternoon ───────────────────────────────────────
  TaskModel(
    id: '4',
    title: 'Write sprint notes',
    time: '13:00',
    priority: TaskPriority.medium,
    section: TaskSection.afternoon,
  ),
  TaskModel(
    id: '5',
    title: 'Code review — PR #42',
    subtitle: 'Auth refactor branch',
    time: '14:30',
    priority: TaskPriority.high,
    section: TaskSection.afternoon,
    isStarred: true,
  ),
  TaskModel(
    id: '6',
    title: 'Grocery run',
    time: '16:00',
    priority: TaskPriority.low,
    section: TaskSection.afternoon,
    isStarred: true,
  ),
  TaskModel(
    id: '10',
    title: 'Client email follow-up',
    subtitle: 'Re: Q2 proposal',
    time: '15:00',
    priority: TaskPriority.high,
    section: TaskSection.afternoon,
  ),

  // ── Evening ─────────────────────────────────────────
  TaskModel(
    id: '7',
    title: 'Read — 30 min',
    subtitle: 'Atomic Habits ch. 9',
    time: '20:00',
    priority: TaskPriority.low,
    section: TaskSection.evening,
  ),
  TaskModel(
    id: '8',
    title: 'Plan tomorrow',
    time: '21:30',
    priority: TaskPriority.medium,
    section: TaskSection.evening,
  ),
  TaskModel(
    id: '11',
    title: 'Dinner prep',
    subtitle: 'Pasta night',
    time: '19:00',
    priority: TaskPriority.medium,
    section: TaskSection.evening,
  ),
];
