import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/data/task_repository.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) {
    final taskRepository = ref.watch(taskRepositoryProvider);

    return AnalyticsRepository(
      taskRepository: taskRepository,
    );
  },
  name: 'analyticsRepositoryProvider',
);

class AnalyticsRepository {
  AnalyticsRepository({
    required TaskRepository taskRepository,
  }) : _taskRepository = taskRepository;

  final TaskRepository _taskRepository;

  Future<Map<String, dynamic>> getProductivitySummary() async {
    final tasks = await _taskRepository.watchAllTasks().first;

    final totalTasks = tasks.length;

    final completedTasks = tasks
        .where(
          (task) => task.isCompleted,
        )
        .length;

    final pendingTasks = totalTasks - completedTasks;

    final completionRate =
        totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100;

    final now = DateTime.now();

    final overdueTasks = tasks.where(
      (task) {
        final dueDate = task.dueDate;

        if (dueDate == null || task.isCompleted) {
          return false;
        }

        return dueDate.isBefore(now);
      },
    ).length;

    return <String, dynamic>{
      'total_tasks': totalTasks,
      'completed_tasks': completedTasks,
      'pending_tasks': pendingTasks,
      'overdue_tasks': overdueTasks,
      'completion_rate': completionRate,
    };
  }
}
