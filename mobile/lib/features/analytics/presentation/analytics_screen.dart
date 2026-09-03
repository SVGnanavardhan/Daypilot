import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_controller.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(analyticsSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Analytics'),
        actions: [
          IconButton(
            tooltip: 'Refresh analytics',
            onPressed: () {
              ref.invalidate(
                analyticsSummaryProvider,
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: analyticsAsync.when(
        loading: () {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return _AnalyticsErrorView(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(
                analyticsSummaryProvider,
              );
            },
          );
        },
        data: (summary) {
          final totalTasks = _readInt(
            summary['total_tasks'],
          );

          final completedTasks = _readInt(
            summary['completed_tasks'],
          );

          final pendingTasks = _readInt(
            summary['pending_tasks'],
          );

          final overdueTasks = _readInt(
            summary['overdue_tasks'],
          );

          final completionRate = _readDouble(
            summary['completion_rate'],
          ).clamp(0.0, 100.0);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                analyticsSummaryProvider,
              );

              await ref.read(
                analyticsSummaryProvider.future,
              );
            },
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
                  'Your Progress',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A quick view of how effectively you are completing your tasks.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                _CompletionCard(
                  completionRate: completionRate,
                  completedTasks: completedTasks,
                  totalTasks: totalTasks,
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _MetricCard(
                      icon: Icons.task_alt_rounded,
                      title: 'Total Tasks',
                      value: '$totalTasks',
                    ),
                    _MetricCard(
                      icon: Icons.check_circle_outline_rounded,
                      title: 'Completed',
                      value: '$completedTasks',
                    ),
                    _MetricCard(
                      icon: Icons.pending_actions_rounded,
                      title: 'Pending',
                      value: '$pendingTasks',
                    ),
                    _MetricCard(
                      icon: Icons.warning_amber_rounded,
                      title: 'Overdue',
                      value: '$overdueTasks',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InsightCard(
                  totalTasks: totalTasks,
                  completedTasks: completedTasks,
                  overdueTasks: overdueTasks,
                  completionRate: completionRate,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static int _readInt(value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static double _readDouble(value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
  });

  final double completionRate;
  final int completedTasks;
  final int totalTasks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            SizedBox(
              width: 88,
              height: 88,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: CircularProgressIndicator(
                      value: completionRate / 100,
                      strokeWidth: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  Text(
                    '${completionRate.toStringAsFixed(0)}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Completion Rate',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    totalTasks == 0
                        ? 'Add tasks to start tracking your productivity.'
                        : '$completedTasks of $totalTasks tasks completed.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 30,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.completionRate,
  });

  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final double completionRate;

  String _buildInsight() {
    if (totalTasks == 0) {
      return 'Create your first task and DayPilot will begin building your productivity picture.';
    }

    if (overdueTasks > 0) {
      return 'You have $overdueTasks overdue ${overdueTasks == 1 ? 'task' : 'tasks'}. Clearing overdue work can improve your daily momentum.';
    }

    if (completionRate >= 80) {
      return 'Strong momentum. You are completing most of the tasks currently in your plan.';
    }

    if (completionRate >= 50) {
      return 'Good progress. Focus on the highest-priority pending tasks to push your completion rate higher.';
    }

    if (completedTasks == 0) {
      return 'Your task list is ready. Start with one achievable task to build momentum.';
    }

    return 'You are making progress. Smaller focused work sessions can help you close more pending tasks.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.auto_awesome_rounded,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DayPilot Insight',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buildInsight(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsErrorView extends StatelessWidget {
  const _AnalyticsErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.insights_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Analytics unavailable',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
