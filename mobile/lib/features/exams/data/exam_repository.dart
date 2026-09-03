class Exam {
  const Exam({
    required this.id,
    required this.title,
    required this.subject,
    required this.examDate,
    this.notes,
  });

  final String id;
  final String title;
  final String subject;
  final DateTime examDate;
  final String? notes;

  int get daysRemaining {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final examDay = DateTime(
      examDate.year,
      examDate.month,
      examDate.day,
    );

    return examDay.difference(startOfToday).inDays;
  }
}

abstract class ExamRepository {
  Future<List<Exam>> getExams();

  Future<Exam?> getExamById(String id);

  Future<void> addExam(Exam exam);

  Future<void> updateExam(Exam exam);

  Future<void> deleteExam(String id);
}

class InMemoryExamRepository implements ExamRepository {
  final List<Exam> _exams = <Exam>[];

  @override
  Future<List<Exam>> getExams() async {
    final exams = List<Exam>.of(_exams)
      ..sort(
        (a, b) => a.examDate.compareTo(b.examDate),
      );

    return List<Exam>.unmodifiable(exams);
  }

  @override
  Future<Exam?> getExamById(String id) async {
    for (final exam in _exams) {
      if (exam.id == id) {
        return exam;
      }
    }

    return null;
  }

  @override
  Future<void> addExam(Exam exam) async {
    _exams.add(exam);
  }

  @override
  Future<void> updateExam(Exam exam) async {
    final index = _exams.indexWhere(
      (item) => item.id == exam.id,
    );

    if (index == -1) {
      throw StateError('Exam not found.');
    }

    _exams[index] = exam;
  }

  @override
  Future<void> deleteExam(String id) async {
    _exams.removeWhere(
      (exam) => exam.id == id,
    );
  }
}
