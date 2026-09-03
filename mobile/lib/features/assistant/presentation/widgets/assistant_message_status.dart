import 'package:flutter/material.dart';

enum AssistantMessageDeliveryStatus {
  sending,
  sent,
  delivered,
  failed,
}

class AssistantMessageStatus extends StatelessWidget {
  const AssistantMessageStatus({
    required this.status,
    super.key,
    this.onRetry,
    this.showLabel = false,
  });

  final AssistantMessageDeliveryStatus status;
  final VoidCallback? onRetry;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isFailed = status == AssistantMessageDeliveryStatus.failed;

    final foregroundColor =
        isFailed ? colorScheme.error : colorScheme.onSurfaceVariant;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == AssistantMessageDeliveryStatus.sending)
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: foregroundColor,
            ),
          )
        else
          Icon(
            _icon,
            size: 14,
            color: foregroundColor,
          ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            _label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (!isFailed || onRetry == null) {
      return Semantics(
        label: _label,
        child: content,
      );
    }

    return Tooltip(
      message: 'Message failed. Tap to retry.',
      child: InkWell(
        onTap: onRetry,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 2,
          ),
          child: content,
        ),
      ),
    );
  }

  IconData get _icon {
    switch (status) {
      case AssistantMessageDeliveryStatus.sending:
        return Icons.schedule_rounded;
      case AssistantMessageDeliveryStatus.sent:
        return Icons.check_rounded;
      case AssistantMessageDeliveryStatus.delivered:
        return Icons.done_all_rounded;
      case AssistantMessageDeliveryStatus.failed:
        return Icons.error_outline_rounded;
    }
  }

  String get _label {
    switch (status) {
      case AssistantMessageDeliveryStatus.sending:
        return 'Sending';
      case AssistantMessageDeliveryStatus.sent:
        return 'Sent';
      case AssistantMessageDeliveryStatus.delivered:
        return 'Delivered';
      case AssistantMessageDeliveryStatus.failed:
        return 'Failed';
    }
  }
}
