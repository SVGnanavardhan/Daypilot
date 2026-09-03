import 'package:flutter/material.dart';

class AssistantCharacterCounter extends StatelessWidget {
  const AssistantCharacterCounter({
    required this.currentLength,
    required this.maxLength,
    super.key,
    this.warningThreshold = 0.8,
  });

  final int currentLength;
  final int maxLength;
  final double warningThreshold;

  @override
  Widget build(BuildContext context) {
    if (maxLength <= 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final safeCurrentLength = currentLength < 0 ? 0 : currentLength;

    final ratio = safeCurrentLength / maxLength;

    final isExceeded = safeCurrentLength > maxLength;
    final isWarning = !isExceeded && ratio >= warningThreshold;

    final color = isExceeded
        ? colorScheme.error
        : isWarning
            ? colorScheme.tertiary
            : colorScheme.onSurfaceVariant;

    return Semantics(
      label: '$safeCurrentLength of $maxLength characters used',
      child: Text(
        '$safeCurrentLength/$maxLength',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight:
              isWarning || isExceeded ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
