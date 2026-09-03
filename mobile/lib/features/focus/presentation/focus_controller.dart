import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/focus_repository.dart';

class FocusState {
  const FocusState({
    this.durationMinutes = 25,
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.isCompleted = false,
    this.totalFocusMinutes = 0,
  });

  final int durationMinutes;
  final int remainingSeconds;
  final bool isRunning;
  final bool isCompleted;
  final int totalFocusMinutes;

  FocusState copyWith({
    int? durationMinutes,
    int? remainingSeconds,
    bool? isRunning,
    bool? isCompleted,
    int? totalFocusMinutes,
  }) {
    return FocusState(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      isCompleted: isCompleted ?? this.isCompleted,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
    );
  }
}

class FocusController extends StateNotifier<FocusState> {
  FocusController({
    required FocusRepository repository,
  })  : _repository = repository,
        super(const FocusState()) {
    unawaited(_loadStats());
  }

  final FocusRepository _repository;

  Timer? _timer;
  DateTime? _sessionStartedAt;

  Future<void> _loadStats() async {
    final total = await _repository.getTotalFocusMinutes();

    state = state.copyWith(
      totalFocusMinutes: total,
    );
  }

  void start() {
    if (state.isRunning) {
      return;
    }

    if (state.remainingSeconds <= 0) {
      reset();
    }

    _sessionStartedAt ??= DateTime.now();

    state = state.copyWith(
      isRunning: true,
      isCompleted: false,
    );

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _tick(),
    );
  }

  void pause() {
    _timer?.cancel();

    state = state.copyWith(
      isRunning: false,
    );
  }

  void reset() {
    _timer?.cancel();
    _sessionStartedAt = null;

    state = state.copyWith(
      remainingSeconds: state.durationMinutes * 60,
      isRunning: false,
      isCompleted: false,
    );
  }

  void setDuration(int minutes) {
    if (state.isRunning || minutes <= 0) {
      return;
    }

    _sessionStartedAt = null;

    state = state.copyWith(
      durationMinutes: minutes,
      remainingSeconds: minutes * 60,
      isCompleted: false,
    );
  }

  Future<void> _tick() async {
    if (state.remainingSeconds <= 1) {
      _timer?.cancel();

      state = state.copyWith(
        remainingSeconds: 0,
        isRunning: false,
        isCompleted: true,
      );

      await _saveCompletedSession();
      return;
    }

    state = state.copyWith(
      remainingSeconds: state.remainingSeconds - 1,
    );
  }

  Future<void> _saveCompletedSession() async {
    final startedAt = _sessionStartedAt ?? DateTime.now();

    final session = FocusSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      startedAt: startedAt,
      durationMinutes: state.durationMinutes,
      completed: true,
    );

    await _repository.saveSession(session);

    _sessionStartedAt = null;

    await _loadStats();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusRepositoryProvider = Provider<FocusRepository>(
  (ref) => InMemoryFocusRepository(),
);

final focusControllerProvider =
    StateNotifierProvider<FocusController, FocusState>(
  (ref) => FocusController(
    repository: ref.watch(focusRepositoryProvider),
  ),
);
