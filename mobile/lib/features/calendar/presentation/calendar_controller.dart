import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/calendar_repository.dart';

class CalendarState {
  const CalendarState({
    required this.selectedDay,
    this.entries = const <CalendarEntry>[],
    this.isLoading = false,
    this.error,
  });

  final DateTime selectedDay;
  final List<CalendarEntry> entries;
  final bool isLoading;
  final String? error;

  CalendarState copyWith({
    DateTime? selectedDay,
    List<CalendarEntry>? entries,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CalendarState(
      selectedDay: selectedDay ?? this.selectedDay,
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CalendarController extends StateNotifier<CalendarState> {
  CalendarController({
    required CalendarRepository repository,
  })  : _repository = repository,
        super(CalendarState(selectedDay: DateTime.now())) {
    unawaited(loadDay(state.selectedDay));
  }

  final CalendarRepository _repository;

  Future<void> selectDay(DateTime day) async {
    state = state.copyWith(selectedDay: day);
    await loadDay(day);
  }

  Future<void> loadDay(DateTime day) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final entries = await _repository.getEntriesForDay(day);

      state = state.copyWith(
        selectedDay: day,
        entries: entries,
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
}

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => const InMemoryCalendarRepository(),
);

final calendarControllerProvider =
    StateNotifierProvider<CalendarController, CalendarState>(
  (ref) => CalendarController(
    repository: ref.watch(calendarRepositoryProvider),
  ),
);
