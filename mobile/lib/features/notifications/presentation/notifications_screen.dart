import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Notification Center',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'DayPilot uses reminders to help you stay ahead of tasks and schedule commitments.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.notifications_active_rounded,
                color: colorScheme.primary,
              ),
              title: const Text('Task Reminders'),
              subtitle: const Text(
                'Reminder notifications can be scheduled before task deadlines.',
              ),
              trailing: const Icon(
                Icons.check_circle_outline_rounded,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.schedule_rounded,
                color: colorScheme.primary,
              ),
              title: const Text('Schedule Alerts'),
              subtitle: const Text(
                'Class and study-session alerts will be connected to the schedule engine.',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.cloud_outlined,
                color: colorScheme.primary,
              ),
              title: const Text('Push Notifications'),
              subtitle: const Text(
                'Firebase Cloud Messaging support is prepared for remote alerts.',
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Notification history and per-category preferences will be added when the notification data layer is connected.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
