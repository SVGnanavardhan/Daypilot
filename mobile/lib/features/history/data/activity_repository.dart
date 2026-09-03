enum ActivityType {
  task,
  focus,
  schedule,
  exam,
  assistant,
  system,
}

class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime createdAt;
}

abstract class ActivityRepository {
  Future<List<ActivityItem>> getActivities();

  Future<void> addActivity(
    ActivityItem activity,
  );

  Future<void> clearActivities();
}

class InMemoryActivityRepository implements ActivityRepository {
  final List<ActivityItem> _activities = <ActivityItem>[];

  @override
  Future<List<ActivityItem>> getActivities() async {
    final activities = List<ActivityItem>.of(_activities)
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

    return List<ActivityItem>.unmodifiable(
      activities,
    );
  }

  @override
  Future<void> addActivity(
    ActivityItem activity,
  ) async {
    _activities.add(activity);
  }

  @override
  Future<void> clearActivities() async {
    _activities.clear();
  }
}
