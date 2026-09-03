import 'package:flutter/material.dart';

/// Empty state widget for displaying when no data is available
///
/// This widget provides a consistent UI for empty states across the app.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    required this.icon,
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured empty states for common scenarios
class EmptyStates {
  /// Empty state for no tasks
  static Widget noTasks({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.task_outlined,
      title: 'No tasks yet',
      message: "You don't have any tasks. Start by creating one!",
      actionLabel: 'Create Task',
      onAction: onAction,
    );
  }

  /// Empty state for no schedule
  static Widget noSchedule({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.calendar_today_outlined,
      title: 'No schedule',
      message: 'Your schedule is empty. Add some events to get started!',
      actionLabel: 'Add Event',
      onAction: onAction,
    );
  }

  /// Empty state for no notifications
  static Widget noNotifications() {
    return const EmptyStateWidget(
      icon: Icons.notifications_outlined,
      title: 'No notifications',
      message: "You're all caught up!",
    );
  }

  /// Empty state for search results
  static Widget noSearchResults() {
    return const EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No results found',
      message: 'Try adjusting your search criteria',
    );
  }

  /// Empty state for no internet
  static Widget noInternet({VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No internet connection',
      message: 'Please check your internet connection and try again',
      actionLabel: 'Retry',
      onAction: onAction,
    );
  }
}
