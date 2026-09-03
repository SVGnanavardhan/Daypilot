import 'package:flutter/material.dart';

enum AssistantActionStatusType {
  pending,
  processing,
  success,
  failed,
}

class AssistantActionStatus extends StatelessWidget {
  const AssistantActionStatus({
    required this.status,
    required this.message,
    super.key,
  });

  final AssistantActionStatusType status;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = _iconForStatus();
    final backgroundColor = _backgroundColor(colorScheme);
    final foregroundColor = _foregroundColor(colorScheme);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (status == AssistantActionStatusType.processing)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: foregroundColor,
              ),
            )
          else
            Icon(
              icon,
              size: 20,
              color: foregroundColor,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForStatus() {
    switch (status) {
      case AssistantActionStatusType.pending:
        return Icons.schedule_rounded;

      case AssistantActionStatusType.processing:
        return Icons.sync_rounded;

      case AssistantActionStatusType.success:
        return Icons.check_circle_outline_rounded;

      case AssistantActionStatusType.failed:
        return Icons.error_outline_rounded;
    }
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    switch (status) {
      case AssistantActionStatusType.pending:
        return colorScheme.surfaceContainerHighest;

      case AssistantActionStatusType.processing:
        return colorScheme.primaryContainer;

      case AssistantActionStatusType.success:
        return colorScheme.tertiaryContainer;

      case AssistantActionStatusType.failed:
        return colorScheme.errorContainer;
    }
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    switch (status) {
      case AssistantActionStatusType.pending:
        return colorScheme.onSurfaceVariant;

      case AssistantActionStatusType.processing:
        return colorScheme.onPrimaryContainer;

      case AssistantActionStatusType.success:
        return colorScheme.onTertiaryContainer;

      case AssistantActionStatusType.failed:
        return colorScheme.onErrorContainer;
    }
  }
}
