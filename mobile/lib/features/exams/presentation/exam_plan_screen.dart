import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'exam_controller.dart';

class ExamPlanScreen extends ConsumerWidget {
  const ExamPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Plan'),
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : state.exams.isEmpty
                ? const _EmptyExamPlan()
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.exams.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final exam = state.exams[index];
                      final days = exam.daysRemaining;

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      exam.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  _DaysBadge(days: days),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                exam.subject,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              LinearProgressIndicator(
                                value: _progress(days),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _message(days),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  double _progress(int days) {
    if (days <= 0) {
      return 1;
    }

    const planningWindow = 30;

    if (days >= planningWindow) {
      return 0;
    }

    return (planningWindow - days) / planningWindow;
  }

  String _message(int days) {
    if (days < 0) {
      return 'Exam completed';
    }

    if (days == 0) {
      return 'Exam is today';
    }

    if (days == 1) {
      return '1 day remaining';
    }

    return '$days days remaining';
  }
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({
    required this.days,
  });

  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days < 0
        ? 'Done'
        : days == 0
            ? 'Today'
            : '${days}d';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EmptyExamPlan extends StatelessWidget {
  const _EmptyExamPlan();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 52,
            ),
            SizedBox(height: 12),
            Text(
              'No exams available to build a study plan.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
