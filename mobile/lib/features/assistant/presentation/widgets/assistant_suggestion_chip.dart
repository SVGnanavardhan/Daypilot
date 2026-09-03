import 'package:flutter/material.dart';

class AssistantSuggestionChip extends StatelessWidget {
  const AssistantSuggestionChip({
    required this.label,
    required this.icon,
    required this.onSelected,
    super.key,
  });

  final String label;
  final IconData icon;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ActionChip(
      avatar: Icon(
        icon,
        size: 18,
        color: theme.colorScheme.primary,
      ),
      label: Text(label),
      tooltip: label,
      onPressed: () {
        onSelected(label);
      },
      side: BorderSide(
        color: theme.colorScheme.outlineVariant,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
