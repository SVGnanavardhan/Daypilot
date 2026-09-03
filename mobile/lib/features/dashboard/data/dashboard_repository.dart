class DashboardSummary {
  const DashboardSummary({
    required this.pendingTasks,
    required this.completedTasks,
    required this.todayEvents,
    required this.focusMinutes,
  });

  final int pendingTasks;
  final int completedTasks;
  final int todayEvents;
  final int focusMinutes;
}

abstract class DashboardRepository {
  Future<DashboardSummary> getSummary();
}

class LocalDashboardRepository implements DashboardRepository {
  const LocalDashboardRepository();

  @override
  Future<DashboardSummary> getSummary() async {
    return const DashboardSummary(
      pendingTasks: 0,
      completedTasks: 0,
      todayEvents: 0,
      focusMinutes: 0,
    );
  }
}
