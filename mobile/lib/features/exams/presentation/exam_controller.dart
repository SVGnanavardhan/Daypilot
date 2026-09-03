import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/exam_repository.dart';

class ExamState {
  const ExamState({
    this.exams = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Exam> exams;
  final bool isLoading;
  final String? error;

  ExamState copyWith({
    List<Exam>? exams,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ExamState(
      exams: exams ?? this.exams,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ExamController extends StateNotifier<ExamState> {
  ExamController({
    required ExamRepository repository,
  })  : _repository = repository,
        super(const ExamState()) {
    unawaited(loadExams());
  }

  final ExamRepository _repository;

  Future<void> loadExams() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final exams = await _repository.getExams();

      state = state.copyWith(
        exams: exams,
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

  Future<void> refresh() => loadExams();

  Future<void> addExam({
    required String title,
    required String subject,
    required DateTime examDate,
    String? notes,
  }) async {
    final exam = Exam(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
      subject: subject.trim(),
      examDate: examDate,
      notes: notes?.trim().isEmpty ?? false ? null : notes?.trim(),
    );

    await _repository.addExam(exam);
    await loadExams();
  }

  Future<void> updateExam(Exam exam) async {
    await _repository.updateExam(exam);
    await loadExams();
  }

  Future<void> deleteExam(String id) async {
    await _repository.deleteExam(id);
    await loadExams();
  }
}

final examRepositoryProvider = Provider<ExamRepository>(
  (ref) => InMemoryExamRepository(),
);

final examControllerProvider = StateNotifierProvider<ExamController, ExamState>(
  (ref) {
    return ExamController(
      repository: ref.watch(examRepositoryProvider),
    );
  },
);
