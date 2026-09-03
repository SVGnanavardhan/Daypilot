import 'package:flutter/material.dart';

class AssistantLabelValue extends StatelessWidget {
  const AssistantLabelValue({
    required this.label,
    required this.value,
    super.key,
    this.icon,
    this.valueColor,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: compact ? 16 : 18,
            color: colorScheme.primary,
          ),
          SizedBox(width: compact ? 6 : 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: compact ? 2 : 4),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
