import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/activity_repository.dart';
import 'activity_controller.dart';

class ActivityHistoryScreen extends ConsumerWidget {
  const ActivityHistoryScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(activityControllerProvider);

    final controller = ref.read(
      activityControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        actions: [
          if (state.activities.isNotEmpty)
            IconButton(
              tooltip: 'Clear history',
              onPressed: () {
                unawaited(
                  _confirmClear(
                    context,
                    controller,
                  ),
                );
              },
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          child: _buildBody(
            context,
            state,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ActivityState state,
  ) {
    if (state.isLoading && state.activities.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 450,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (state.error != null && state.activities.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          const Icon(
            Icons.error_outline,
            size: 52,
          ),
          const SizedBox(height: 12),
          Text(
            state.error!,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (state.activities.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 100),
          Icon(
            Icons.history_rounded,
            size: 56,
          ),
          SizedBox(height: 12),
          Text(
            'No activity yet.',
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6),
          Text(
            'Your DayPilot activity will appear here.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: state.activities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final activity = state.activities[index];

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Icon(
                _iconFor(activity.type),
              ),
            ),
            title: Text(activity.title),
            subtitle: Text(
              '${activity.description}\n'
              '${_formatDate(activity.createdAt)}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    ActivityController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear history?'),
          content: const Text(
            'This will remove all activity history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await controller.clear();
    }
  }

  static IconData _iconFor(
    ActivityType type,
  ) {
    switch (type) {
      case ActivityType.task:
        return Icons.task_alt;

      case ActivityType.focus:
        return Icons.timer_outlined;

      case ActivityType.schedule:
        return Icons.calendar_month_outlined;

      case ActivityType.exam:
        return Icons.school_outlined;

      case ActivityType.assistant:
        return Icons.auto_awesome_outlined;

      case ActivityType.system:
        return Icons.settings_outlined;
    }
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • $hour:$minute';
  }
}
