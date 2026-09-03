import 'package:flutter/material.dart';

class AssistantPromptExamples extends StatelessWidget {
  const AssistantPromptExamples({
    required this.prompts,
    required this.onSelected,
    super.key,
    this.title = 'Try asking',
    this.icon = Icons.lightbulb_outline_rounded,
    this.enabled = true,
  });

  final List<String> prompts;
  final ValueChanged<String> onSelected;
  final String title;
  final IconData icon;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final visiblePrompts = prompts
        .where((prompt) => prompt.trim().isNotEmpty)
        .toList(growable: false);

    if (visiblePrompts.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 7),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: visiblePrompts
              .map(
                (prompt) => ActionChip(
                  label: Text(prompt),
                  avatar: const Icon(
                    Icons.arrow_upward_rounded,
                    size: 15,
                  ),
                  onPressed: enabled ? () => onSelected(prompt) : null,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
