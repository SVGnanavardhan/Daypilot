import 'package:flutter/material.dart';

enum AssistantStatus {
  online,
  offline,
  connecting,
  error,
}

class AssistantStatusBanner extends StatelessWidget {
  const AssistantStatusBanner({
    required this.status,
    super.key,
    this.message,
  });

  final AssistantStatus status;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final config = _getConfig(colorScheme);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      color: config.backgroundColor,
      child: Row(
        children: [
          if (status == AssistantStatus.connecting)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: config.foregroundColor,
              ),
            )
          else
            Icon(
              config.icon,
              size: 17,
              color: config.foregroundColor,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? config.message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: config.foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _getConfig(
    ColorScheme colorScheme,
  ) {
    switch (status) {
      case AssistantStatus.online:
        return _StatusConfig(
          icon: Icons.check_circle_outline_rounded,
          message: 'DayPilot Assistant is ready',
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        );

      case AssistantStatus.offline:
        return _StatusConfig(
          icon: Icons.cloud_off_outlined,
          message: 'Assistant is currently offline',
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
        );

      case AssistantStatus.connecting:
        return _StatusConfig(
          icon: Icons.sync_rounded,
          message: 'Connecting to DayPilot Assistant...',
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        );

      case AssistantStatus.error:
        return _StatusConfig(
          icon: Icons.error_outline_rounded,
          message: 'Assistant connection failed',
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.icon,
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
}
