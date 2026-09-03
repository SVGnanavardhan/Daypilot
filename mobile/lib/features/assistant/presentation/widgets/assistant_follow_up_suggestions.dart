import 'package:flutter/material.dart';

class AssistantFollowUpSuggestions extends StatelessWidget {
  const AssistantFollowUpSuggestions({
    required this.suggestions,
    required this.onSelected,
    super.key,
    this.title = 'You can also ask',
    this.enabled = true,
  });

  final List<String> suggestions;
  final ValueChanged<String> onSelected;
  final String title;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions
              .where((suggestion) => suggestion.trim().isNotEmpty)
              .map(
                (suggestion) => ActionChip(
                  avatar: Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 16,
                    color: enabled
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  label: Text(suggestion),
                  onPressed: enabled ? () => onSelected(suggestion) : null,
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}
