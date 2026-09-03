// ignore_for_file: cascade_invocations

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../schedule/presentation/schedule_controller.dart';
import '../../../tasks/presentation/task_controller.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    final scheduleAsync = ref.watch(scheduleProvider);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DayPilot'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () {
              unawaited(context.push('/notifications'));
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              unawaited(context.push('/profile'));
            },
            icon: const Icon(Icons.person_outline_rounded),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: () {
              unawaited(context.push('/settings'));
            },
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) {
          return _DashboardError(
            message: error.toString(),
            onRetry: () {
              ref.invalidate(tasksStreamProvider);
            },
          );
        },
        data: (tasks) {
          final pending = tasks.where((task) => !task.isCompleted).toList();
          final completed = tasks.where((task) => task.isCompleted).toList();

          final productivityScore = tasks.isEmpty
              ? 0
              : ((completed.length / tasks.length) * 100).round();

          final now = DateTime.now();

          final todayTasks = pending.where(
            (task) {
              final dueDate = task.dueDate;

              if (dueDate == null) {
                return false;
              }

              return _isSameDay(dueDate, now);
            },
          ).toList()
            ..sort(
              (a, b) {
                final aDue = a.dueDate;
                final bDue = b.dueDate;

                if (aDue == null && bDue == null) {
                  return 0;
                }

                if (aDue == null) {
                  return 1;
                }

                if (bDue == null) {
                  return -1;
                }

                return aDue.compareTo(bDue);
              },
            );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tasksStreamProvider);
              ref.invalidate(scheduleProvider);

              await Future<void>.delayed(
                const Duration(milliseconds: 300),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  _greeting(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Let DayPilot organize your day.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _AiPlannerCard(
                  pendingCount: pending.length,
                  onOpenPlanner: () {
                    unawaited(context.push('/planner'));
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.insights_rounded,
                      color: colorScheme.primary,
                    ),
                    title: const Text('Productivity Score'),
                    subtitle: Text(
                      tasks.isEmpty
                          ? 'Complete tasks to build your score'
                          : '${completed.length} of ${tasks.length} tasks completed',
                    ),
                    trailing: Text(
                      '$productivityScore%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.pending_actions_rounded,
                        label: 'Pending',
                        value: '${pending.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.today_rounded,
                        label: 'Today',
                        value: '${todayTasks.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.task_alt_rounded,
                        label: 'Done',
                        value: '${completed.length}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: "Today's Tasks",
                  actionLabel: 'View All',
                  onAction: () {
                    context.go('/tasks');
                  },
                ),
                const SizedBox(height: 8),
                if (todayTasks.isEmpty)
                  Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.check_circle_outline_rounded,
                        color: colorScheme.primary,
                      ),
                      title: const Text('No tasks due today'),
                      subtitle: const Text(
                        'Your day is clear. Add a task or generate a plan.',
                      ),
                      trailing: IconButton(
                        tooltip: 'Add task',
                        onPressed: () {
                          context.go('/tasks');
                        },
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ),
                  )
                else
                  ...todayTasks.take(4).map(
                    (task) {
                      final description = task.description?.trim();

                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.task_alt_outlined,
                            color: colorScheme.primary,
                          ),
                          title: Text(task.title),
                          subtitle: Text(
                            description != null && description.isNotEmpty
                                ? description
                                : 'Due today',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                          ),
                          onTap: () {
                            context.go('/tasks');
                          },
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Upcoming Schedule',
                  actionLabel: 'View Schedule',
                  onAction: () {
                    context.go('/schedule');
                  },
                ),
                const SizedBox(height: 8),
                scheduleAsync.when(
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: LinearProgressIndicator(),
                    ),
                  ),
                  error: (error, stackTrace) {
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.error,
                        ),
                        title: const Text('Unable to load schedule'),
                        subtitle: const Text(
                          'Pull down to refresh and try again.',
                        ),
                      ),
                    );
                  },
                  data: (entries) {
                    if (entries.isEmpty) {
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.event_busy_rounded,
                            color: colorScheme.primary,
                          ),
                          title: const Text('No upcoming schedule'),
                          subtitle: const Text(
                            'Add classes or study sessions to your schedule.',
                          ),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                          ),
                          onTap: () {
                            context.go('/schedule');
                          },
                        ),
                      );
                    }

                    return Column(
                      children: entries.take(3).map(
                        (entry) {
                          final title = entry['title']?.toString().trim();
                          final day = entry['day_of_week']?.toString().trim();
                          final start = entry['start_time']?.toString().trim();
                          final end = entry['end_time']?.toString().trim();

                          final scheduleParts = <String>[
                            if (day != null && day.isNotEmpty) day,
                            if (start != null &&
                                start.isNotEmpty &&
                                end != null &&
                                end.isNotEmpty)
                              '$start - $end',
                          ];

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                Icons.calendar_month_outlined,
                                color: colorScheme.primary,
                              ),
                              title: Text(
                                title == null || title.isEmpty
                                    ? 'Scheduled Event'
                                    : title,
                              ),
                              subtitle: Text(
                                scheduleParts.isEmpty
                                    ? 'Schedule details'
                                    : scheduleParts.join(' • '),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                              ),
                              onTap: () {
                                context.go('/schedule');
                              },
                            ),
                          );
                        },
                      ).toList(),
                    );
                  },
                ),
                const SizedBox(height: 28),
                Text(
                  'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.add_task_rounded,
                        label: 'Add Task',
                        onTap: () {
                          context.go('/tasks');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.calendar_month_rounded,
                        label: 'Schedule',
                        onTap: () {
                          context.go('/schedule');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.auto_awesome_rounded,
                        label: 'AI Planner',
                        onTap: () {
                          unawaited(context.push('/planner'));
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        onTap: () {
                          unawaited(context.push('/profile'));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/tasks');
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Quick Add'),
      ),
    );
  }

  static bool _isSameDay(
    DateTime first,
    DateTime second,
  ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning!';
    }

    if (hour < 17) {
      return 'Good Afternoon!';
    }

    return 'Good Evening!';
  }
}

class _AiPlannerCard extends StatelessWidget {
  const _AiPlannerCard({
    required this.pendingCount,
    required this.onOpenPlanner,
  });

  final int pendingCount;
  final VoidCallback onOpenPlanner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                Expanded(
                  child: Text(
                    'AI Plan for Today',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              pendingCount == 0
                  ? 'You have no pending tasks. Add tasks and DayPilot can organize them for you.'
                  : '$pendingCount pending ${pendingCount == 1 ? 'task is' : 'tasks are'} ready for smart planning.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenPlanner,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generate AI Plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 22,
            horizontal: 8,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 30,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({
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
              'Unable to load dashboard',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
