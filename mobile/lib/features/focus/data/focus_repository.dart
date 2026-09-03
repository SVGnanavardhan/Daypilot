class FocusSession {
  const FocusSession({
    required this.id,
    required this.startedAt,
    required this.durationMinutes,
    required this.completed,
    this.taskId,
  });

  final String id;
  final DateTime startedAt;
  final int durationMinutes;
  final bool completed;
  final String? taskId;
}

abstract class FocusRepository {
  Future<List<FocusSession>> getSessions();

  Future<void> saveSession(FocusSession session);

  Future<int> getTotalFocusMinutes();
}

class InMemoryFocusRepository implements FocusRepository {
  final List<FocusSession> _sessions = <FocusSession>[];

  @override
  Future<List<FocusSession>> getSessions() async {
    final sessions = List<FocusSession>.of(_sessions)
      ..sort(
        (a, b) => b.startedAt.compareTo(a.startedAt),
      );

    return List<FocusSession>.unmodifiable(
      sessions,
    );
  }

  @override
  Future<void> saveSession(
    FocusSession session,
  ) async {
    _sessions.add(session);
  }

  @override
  Future<int> getTotalFocusMinutes() async {
    return _sessions.where((session) => session.completed).fold<int>(
          0,
          (total, session) => total + session.durationMinutes,
        );
  }
}
