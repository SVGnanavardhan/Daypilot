import 'package:flutter/material.dart';

import '../../data/recommendation_repository.dart';

class RecommendationPriorityBadge extends StatelessWidget {
  const RecommendationPriorityBadge({
    required this.priority,
    super.key,
  });

  final RecommendationPriority priority;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _background(colors),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: _foreground(colors),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String get _label {
    switch (priority) {
      case RecommendationPriority.low:
        return 'Low';
      case RecommendationPriority.medium:
        return 'Medium';
      case RecommendationPriority.high:
        return 'High';
    }
  }

  Color _background(ColorScheme colors) {
    switch (priority) {
      case RecommendationPriority.low:
        return colors.surfaceContainerHighest;
      case RecommendationPriority.medium:
        return colors.secondaryContainer;
      case RecommendationPriority.high:
        return colors.primaryContainer;
    }
  }

  Color _foreground(ColorScheme colors) {
    switch (priority) {
      case RecommendationPriority.low:
        return colors.onSurfaceVariant;
      case RecommendationPriority.medium:
        return colors.onSecondaryContainer;
      case RecommendationPriority.high:
        return colors.onPrimaryContainer;
    }
  }
}
