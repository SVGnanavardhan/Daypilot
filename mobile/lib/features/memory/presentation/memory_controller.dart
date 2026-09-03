import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/memory_repository.dart';

class MemoryState {
  const MemoryState({
    this.items = const <MemoryItem>[],
    this.isLoading = false,
    this.error,
  });

  final List<MemoryItem> items;
  final bool isLoading;
  final String? error;

  MemoryState copyWith({
    List<MemoryItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return MemoryState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class MemoryController extends StateNotifier<MemoryState> {
  MemoryController({
    required MemoryRepository repository,
  })  : _repository = repository,
        super(const MemoryState()) {
    unawaited(loadMemories());
  }

  final MemoryRepository _repository;

  Future<void> loadMemories() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final items = await _repository.getMemories();

      state = state.copyWith(
        items: items,
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

  Future<void> addMemory({
    required String title,
    required String content,
  }) async {
    final cleanTitle = title.trim();
    final cleanContent = content.trim();

    if (cleanTitle.isEmpty || cleanContent.isEmpty) {
      return;
    }

    await _repository.saveMemory(
      MemoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: cleanTitle,
        content: cleanContent,
        createdAt: DateTime.now(),
      ),
    );

    await loadMemories();
  }

  Future<void> deleteMemory(String id) async {
    await _repository.deleteMemory(id);
    await loadMemories();
  }

  Future<void> clear() async {
    await _repository.clearMemories();
    await loadMemories();
  }

  Future<void> refresh() => loadMemories();
}

final memoryRepositoryProvider = Provider<MemoryRepository>(
  (ref) => InMemoryMemoryRepository(),
);

final memoryControllerProvider =
    StateNotifierProvider<MemoryController, MemoryState>(
  (ref) => MemoryController(
    repository: ref.watch(memoryRepositoryProvider),
  ),
);
