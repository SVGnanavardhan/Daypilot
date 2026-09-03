import 'recommendation_repository.dart';

class RecommendationEngine {
  const RecommendationEngine();

  List<RecommendationItem> prioritize(
    Iterable<RecommendationItem> recommendations,
  ) {
    final items = List<RecommendationItem>.of(recommendations)
      ..sort(
        (a, b) {
          final priorityComparison =
              _priorityValue(b.priority).compareTo(_priorityValue(a.priority));

          if (priorityComparison != 0) {
            return priorityComparison;
          }

          final aDate = a.createdAt;
          final bDate = b.createdAt;

          if (aDate == null && bDate == null) {
            return 0;
          }

          if (aDate == null) {
            return 1;
          }

          if (bDate == null) {
            return -1;
          }

          return bDate.compareTo(aDate);
        },
      );

    return List<RecommendationItem>.unmodifiable(items);
  }

  int _priorityValue(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.low:
        return 1;

      case RecommendationPriority.medium:
        return 2;

      case RecommendationPriority.high:
        return 3;
    }
  }
}
