import 'package:flutter/material.dart';

class AssistantOfflineBanner extends StatelessWidget {
  const AssistantOfflineBanner({
    super.key,
    this.message =
        'You are offline. Some assistant features may be unavailable.',
    this.onRetry,
    this.isRetrying = false,
  });

  final String message;
  final VoidCallback? onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.tertiaryContainer,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 20,
                color: colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    height: 1.35,
                  ),
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(width: 8),
                if (isRetrying)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  )
                else
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onTertiaryContainer,
                      visualDensity: VisualDensity.compact,
                    ),
                    child: const Text('Retry'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
