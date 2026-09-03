import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/recommendation_engine.dart';
import '../data/recommendation_repository.dart';

class RecommendationState {
  const RecommendationState({
    this.items = const <RecommendationItem>[],
    this.isLoading = false,
    this.error,
  });

  final List<RecommendationItem> items;
  final bool isLoading;
  final String? error;

  RecommendationState copyWith({
    List<RecommendationItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RecommendationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class RecommendationController extends StateNotifier<RecommendationState> {
  RecommendationController({
    required RecommendationRepository repository,
    required RecommendationEngine engine,
  })  : _repository = repository,
        _engine = engine,
        super(const RecommendationState()) {
    unawaited(loadRecommendations());
  }

  final RecommendationRepository _repository;
  final RecommendationEngine _engine;

  Future<void> loadRecommendations() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final recommendations = await _repository.getRecommendations();
      final prioritized = _engine.prioritize(recommendations);

      state = state.copyWith(
        items: prioritized,
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

  Future<void> accept(String id) async {
    try {
      await _repository.markRecommendationAccepted(id);
      await loadRecommendations();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> dismiss(String id) async {
    try {
      await _repository.dismissRecommendation(id);
      await loadRecommendations();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> refresh() => loadRecommendations();
}

final recommendationRepositoryProvider = Provider<RecommendationRepository>(
  (ref) => InMemoryRecommendationRepository(),
);

final recommendationEngineProvider = Provider<RecommendationEngine>(
  (ref) => const RecommendationEngine(),
);

final recommendationControllerProvider =
    StateNotifierProvider<RecommendationController, RecommendationState>(
  (ref) => RecommendationController(
    repository: ref.watch(recommendationRepositoryProvider),
    engine: ref.watch(recommendationEngineProvider),
  ),
);
