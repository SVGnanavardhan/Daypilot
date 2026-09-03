import 'package:flutter/material.dart';

import '../../data/recommendation_repository.dart';

class RecommendationTypeIcon extends StatelessWidget {
  const RecommendationTypeIcon({required this.type, super.key, this.size = 42});

  final RecommendationType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, color: colors.onPrimaryContainer, size: size * 0.55),
    );
  }

  IconData get _icon {
    switch (type) {
      case RecommendationType.task:
        return Icons.task_alt_rounded;
      case RecommendationType.schedule:
        return Icons.calendar_month_rounded;
      case RecommendationType.focus:
        return Icons.center_focus_strong_rounded;
      case RecommendationType.productivity:
        return Icons.insights_rounded;
      case RecommendationType.reminder:
        return Icons.notifications_active_rounded;
    }
  }
}
