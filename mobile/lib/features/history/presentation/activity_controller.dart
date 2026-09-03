import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/activity_repository.dart';

class ActivityState {
  const ActivityState({
    this.activities = const <ActivityItem>[],
    this.isLoading = false,
    this.error,
  });

  final List<ActivityItem> activities;
  final bool isLoading;
  final String? error;

  ActivityState copyWith({
    List<ActivityItem>? activities,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ActivityController extends StateNotifier<ActivityState> {
  ActivityController({
    required ActivityRepository repository,
  })  : _repository = repository,
        super(const ActivityState()) {
    unawaited(loadActivities());
  }

  final ActivityRepository _repository;

  Future<void> loadActivities() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final activities = await _repository.getActivities();

      state = state.copyWith(
        activities: activities,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> addActivity({
    required String title,
    required String description,
    required ActivityType type,
  }) async {
    final activity = ActivityItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      createdAt: DateTime.now(),
    );

    await _repository.addActivity(activity);
    await loadActivities();
  }

  Future<void> clear() async {
    await _repository.clearActivities();
    await loadActivities();
  }

  Future<void> refresh() => loadActivities();
}

final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => InMemoryActivityRepository(),
);

final activityControllerProvider =
    StateNotifierProvider<ActivityController, ActivityState>(
  (ref) => ActivityController(
    repository: ref.watch(activityRepositoryProvider),
  ),
);
