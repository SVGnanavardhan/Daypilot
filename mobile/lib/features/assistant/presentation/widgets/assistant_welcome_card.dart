import 'package:flutter/material.dart';

class AssistantWelcomeCard extends StatelessWidget {
  const AssistantWelcomeCard({
    super.key,
    this.userName,
  });

  final String? userName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final name = userName?.trim();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 32,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(height: 14),
          Text(
            name != null && name.isNotEmpty ? 'Hi $name 👋' : 'Hi 👋',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'I’m your DayPilot Assistant.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I can help you prioritize tasks, plan your day, '
            'find free time, organize your schedule, and '
            'stay focused on what matters next.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
