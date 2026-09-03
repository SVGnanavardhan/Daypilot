class RecommendationItem {
  const RecommendationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.priority = RecommendationPriority.medium,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final RecommendationType type;
  final RecommendationPriority priority;
  final DateTime? createdAt;
}

enum RecommendationType { task, schedule, focus, productivity, reminder }

enum RecommendationPriority { low, medium, high }

abstract class RecommendationRepository {
  Future<List<RecommendationItem>> getRecommendations();
  Future<void> dismissRecommendation(String recommendationId);
  Future<void> markRecommendationAccepted(String recommendationId);
}

class InMemoryRecommendationRepository implements RecommendationRepository {
  final List<RecommendationItem> _recommendations = <RecommendationItem>[
    RecommendationItem(
      id: 'focus-session',
      title: 'Start a focus session',
      description:
          'You have an open time block. Use it for your highest-priority task.',
      type: RecommendationType.focus,
      priority: RecommendationPriority.high,
      createdAt: DateTime.now(),
    ),
    RecommendationItem(
      id: 'review-tasks',
      title: "Review today's tasks",
      description:
          'Check your pending tasks and move the most important one to the top.',
      type: RecommendationType.task,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<RecommendationItem>> getRecommendations() async =>
      List<RecommendationItem>.unmodifiable(_recommendations);

  @override
  Future<void> dismissRecommendation(String recommendationId) async {
    _recommendations.removeWhere((item) => item.id == recommendationId);
  }

  @override
  Future<void> markRecommendationAccepted(String recommendationId) async {
    _recommendations.removeWhere((item) => item.id == recommendationId);
  }
}
