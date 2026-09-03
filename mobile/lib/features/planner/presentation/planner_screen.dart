import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/supabase_config.dart';
import '../data/reschedule_service.dart';
import 'planner_controller.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  bool _isRescheduling = false;

  Future<void> _refreshPlan() async {
    ref.invalidate(plannerProvider);

    await ref.read(plannerProvider.future);
  }

  Future<void> _rescheduleMissedTasks() async {
    if (_isRescheduling) {
      return;
    }

    setState(() {
      _isRescheduling = true;
    });

    try {
      final supabase = ref.read(supabaseClientProvider);

      final service = RescheduleService(
        supabase,
      );

      final count = await service.rescheduleMissedTasks();

      ref.invalidate(plannerProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 0
                ? 'No missed tasks found.'
                : '$count missed ${count == 1 ? 'task was' : 'tasks were'} rescheduled.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to reschedule tasks: $error',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRescheduling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plannerAsync = ref.watch(plannerProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Planner'),
        actions: [
          IconButton(
            tooltip: 'Refresh plan',
            onPressed: _isRescheduling
                ? null
                : () {
                    ref.invalidate(
                      plannerProvider,
                    );
                  },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Reschedule missed tasks',
            onPressed: _isRescheduling ? null : _rescheduleMissedTasks,
            icon: _isRescheduling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(
                    Icons.update_rounded,
                  ),
          ),
        ],
      ),
      body: plannerAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _PlannerErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(plannerProvider);
            },
          );
        },
        data: (tasks) {
          if (tasks.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshPlan,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * 0.65,
                    child: const _EmptyPlannerView(),
                  ),
                ],
              ),
            );
          }

          final recommended = tasks.first;

          return RefreshIndicator(
            onRefresh: _refreshPlan,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              children: [
                Text(
                  'Recommended Now',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _RecommendedTaskCard(
                  task: recommended,
                ),
                const SizedBox(height: 28),
                Text(
                  "Today's Plan",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...tasks.take(6).indexed.map(
                  (indexedTask) {
                    final index = indexedTask.$1;

                    final task = indexedTask.$2;

                    return _PlanTaskCard(
                      position: index + 1,
                      task: task,
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _isRescheduling ? null : _rescheduleMissedTasks,
                    icon: _isRescheduling
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.schedule_send_rounded,
                          ),
                    label: Text(
                      _isRescheduling
                          ? 'Rescheduling...'
                          : 'Reschedule Missed Tasks',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.lightbulb_outline,
                      color: colorScheme.primary,
                    ),
                    title: const Text(
                      'How DayPilot ranks tasks',
                    ),
                    subtitle: const Text(
                      'Your plan considers priority, deadlines, estimated duration, and recommended study slots.',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecommendedTaskCard extends StatelessWidget {
  const _RecommendedTaskCard({
    required this.task,
  });

  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final title = task['title']?.toString().trim();

    final subject = task['subject']?.toString().trim();

    final priority = task['priority']?.toString().trim();

    final duration = task['estimated_duration'];

    final slot = task['recommended_slot']?.toString().trim();

    final score = task['planner_score'];

    final dueAt = task['due_at']?.toString();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Best task to do now',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              title == null || title.isEmpty ? 'Untitled Task' : title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subject != null && subject.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.book_outlined,
                label: 'Subject',
                value: subject,
              ),
            ],
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.flag_outlined,
              label: 'Priority',
              value: priority == null || priority.isEmpty ? 'Medium' : priority,
            ),
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: '${duration ?? 30} min',
            ),
            if (slot != null && slot.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Best Slot',
                value: slot,
              ),
            ],
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.insights_outlined,
              label: 'Smart Score',
              value: score?.toString() ?? '0',
            ),
            if (dueAt != null && dueAt.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'Due',
                value: _formatDateTime(dueAt),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDateTime(
    String value,
  ) {
    final parsed = DateTime.tryParse(value);

    if (parsed == null) {
      return value;
    }

    final day = parsed.day.toString().padLeft(2, '0');

    final month = parsed.month.toString().padLeft(2, '0');

    return '$day/$month/${parsed.year}';
  }
}

class _PlanTaskCard extends StatelessWidget {
  const _PlanTaskCard({
    required this.position,
    required this.task,
  });

  final int position;
  final Map<String, dynamic> task;

  @override
  Widget build(BuildContext context) {
    final title = task['title']?.toString().trim();

    final priority = task['priority']?.toString().trim();

    final duration = task['estimated_duration'];

    final slot = task['recommended_slot']?.toString().trim();

    final score = task['planner_score'];

    final subtitleParts = <String>[
      if (priority == null || priority.isEmpty) 'Medium' else priority,
      '${duration ?? 30} min',
      if (slot != null && slot.isNotEmpty) slot,
    ];

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            '$position',
          ),
        ),
        title: Text(
          title == null || title.isEmpty ? 'Untitled Task' : title,
        ),
        subtitle: Text(
          subtitleParts.join(' • '),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Score',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text(
              score?.toString() ?? '0',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _EmptyPlannerView extends StatelessWidget {
  const _EmptyPlannerView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              size: 72,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Your plan is clear',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add pending tasks and DayPilot will prioritize them for you.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlannerErrorView extends StatelessWidget {
  const _PlannerErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to generate plan',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
