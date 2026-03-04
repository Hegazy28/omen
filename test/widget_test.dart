import 'package:flutter_test/flutter_test.dart';
import 'package:omen/component/tasks/task_model.dart';

void main() {
  test('TaskModel map serialization round-trip', () {
    const task = TaskModel(
      id: 't1',
      title: 'Read Quran',
      subtitle: 'Surah Al-Kahf',
      time: '08:00',
      priority: TaskPriority.high,
      section: TaskSection.morning,
      isCompleted: true,
      isStarred: true,
    );

    final map = task.toMap();
    final restored = TaskModel.fromMap(map);

    expect(restored.id, task.id);
    expect(restored.title, task.title);
    expect(restored.subtitle, task.subtitle);
    expect(restored.time, task.time);
    expect(restored.priority, task.priority);
    expect(restored.section, task.section);
    expect(restored.isCompleted, task.isCompleted);
    expect(restored.isStarred, task.isStarred);
  });
}
