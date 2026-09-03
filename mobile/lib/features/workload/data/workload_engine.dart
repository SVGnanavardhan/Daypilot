enum WorkloadLevel {
  light,
  balanced,
  busy,
  overloaded,
}

class WorkloadResult {
  const WorkloadResult({
    required this.level,
    required this.score,
    required this.message,
  });

  final WorkloadLevel level;
  final int score;
  final String message;
}

class WorkloadEngine {
  const WorkloadEngine();

  WorkloadResult calculate({
    required int pendingTasks,
    required int estimatedMinutes,
    required int availableMinutes,
  }) {
    if (pendingTasks <= 0 || estimatedMinutes <= 0) {
      return const WorkloadResult(
        level: WorkloadLevel.light,
        score: 0,
        message: 'Your workload is light. You have space for additional work.',
      );
    }

    if (availableMinutes <= 0) {
      return const WorkloadResult(
        level: WorkloadLevel.overloaded,
        score: 100,
        message:
            'Your available time is full. Consider rescheduling lower-priority tasks.',
      );
    }

    final utilization = estimatedMinutes / availableMinutes;

    final taskPressure = (pendingTasks * 5).clamp(0, 30);

    final utilizationScore = (utilization * 70).round().clamp(0, 70);

    final score = (utilizationScore + taskPressure).clamp(0, 100);

    if (score < 35) {
      return WorkloadResult(
        level: WorkloadLevel.light,
        score: score,
        message: 'Your workload is manageable with plenty of free capacity.',
      );
    }

    if (score < 65) {
      return WorkloadResult(
        level: WorkloadLevel.balanced,
        score: score,
        message: 'Your workload is balanced. Continue with your current plan.',
      );
    }

    if (score < 85) {
      return WorkloadResult(
        level: WorkloadLevel.busy,
        score: score,
        message:
            'You have a busy schedule. Focus on high-priority tasks first.',
      );
    }

    return WorkloadResult(
      level: WorkloadLevel.overloaded,
      score: score,
      message:
          'Your workload is overloaded. Reschedule or reduce lower-priority work.',
    );
  }
}
