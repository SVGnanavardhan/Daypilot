import 'package:flutter/material.dart';

enum AssistantProcessingStepStatus {
  pending,
  processing,
  completed,
  failed,
}

class AssistantProcessingStep extends StatelessWidget {
  const AssistantProcessingStep({
    required this.title,
    super.key,
    this.subtitle,
    this.status = AssistantProcessingStepStatus.pending,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final AssistantProcessingStepStatus status;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isFailed = status == AssistantProcessingStepStatus.failed;

    final foregroundColor =
        isFailed ? colorScheme.error : _statusColor(colorScheme);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: Center(
            child: status == AssistantProcessingStepStatus.processing
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                : Icon(
                    _statusIcon,
                    size: 20,
                    color: foregroundColor,
                  ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isFailed ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isFailed && onRetry != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRetry,
            tooltip: 'Retry',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 19,
            ),
          ),
        ],
      ],
    );
  }

  Color _statusColor(ColorScheme colorScheme) {
    switch (status) {
      case AssistantProcessingStepStatus.pending:
        return colorScheme.onSurfaceVariant;
      case AssistantProcessingStepStatus.processing:
        return colorScheme.primary;
      case AssistantProcessingStepStatus.completed:
        return colorScheme.primary;
      case AssistantProcessingStepStatus.failed:
        return colorScheme.error;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case AssistantProcessingStepStatus.pending:
        return Icons.radio_button_unchecked_rounded;
      case AssistantProcessingStepStatus.processing:
        return Icons.hourglass_top_rounded;
      case AssistantProcessingStepStatus.completed:
        return Icons.check_circle_rounded;
      case AssistantProcessingStepStatus.failed:
        return Icons.error_outline_rounded;
    }
  }
}
