import 'package:flutter/material.dart';

class AssistantEmptyState extends StatelessWidget {
  const AssistantEmptyState({
    super.key,
    this.onSuggestionSelected,
  });

  final ValueChanged<String>? onSuggestionSelected;

  static const List<_AssistantSuggestion> _suggestions = [
    _AssistantSuggestion(
      icon: Icons.calendar_today_outlined,
      text: 'Help me plan my day',
    ),
    _AssistantSuggestion(
      icon: Icons.task_alt_outlined,
      text: 'What task should I focus on?',
    ),
    _AssistantSuggestion(
      icon: Icons.schedule_outlined,
      text: 'Help me organize my schedule',
    ),
    _AssistantSuggestion(
      icon: Icons.insights_outlined,
      text: 'How can I improve my productivity?',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 42,
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 42,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'How can I help?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask DayPilot about your tasks, schedule, study plan, or productivity.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          ..._suggestions.map(
            (suggestion) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                ),
                child: Card(
                  child: ListTile(
                    leading: Icon(
                      suggestion.icon,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      suggestion.text,
                    ),
                    trailing: onSuggestionSelected == null
                        ? null
                        : const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                          ),
                    onTap: onSuggestionSelected == null
                        ? null
                        : () {
                            onSuggestionSelected!(
                              suggestion.text,
                            );
                          },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AssistantSuggestion {
  const _AssistantSuggestion({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;
}
