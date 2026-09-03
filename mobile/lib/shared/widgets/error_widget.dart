import 'package:flutter/material.dart';

/// Error widget for displaying error states
///
/// This widget provides a consistent UI for error states across the app.
class ErrorWidgetCustom extends StatelessWidget {
  const ErrorWidgetCustom({
    required this.title,
    super.key,
    this.message,
    this.actionLabel,
    this.onAction,
    this.icon,
  });
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pre-configured error states for common scenarios
class ErrorStates {
  /// Error state for generic errors
  static Widget generic({
    String? message,
    VoidCallback? onRetry,
  }) {
    return ErrorWidgetCustom(
      icon: Icons.error_outline,
      title: 'Something went wrong',
      message: message ?? 'An unexpected error occurred',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Error state for network errors
  static Widget network({VoidCallback? onRetry}) {
    return ErrorWidgetCustom(
      icon: Icons.wifi_off,
      title: 'Network error',
      message:
          'Failed to connect to the server. Please check your internet connection.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Error state for server errors
  static Widget server({VoidCallback? onRetry}) {
    return ErrorWidgetCustom(
      icon: Icons.cloud_off,
      title: 'Server error',
      message: 'The server is experiencing issues. Please try again later.',
      actionLabel: 'Retry',
      onAction: onRetry,
    );
  }

  /// Error state for authentication errors
  static Widget authentication({VoidCallback? onAction}) {
    return ErrorWidgetCustom(
      icon: Icons.lock_outline,
      title: 'Authentication error',
      message: 'You need to log in to access this feature',
      actionLabel: 'Log In',
      onAction: onAction,
    );
  }

  /// Error state for permission errors
  static Widget permission({VoidCallback? onAction}) {
    return ErrorWidgetCustom(
      icon: Icons.block,
      title: 'Permission denied',
      message: "You don't have permission to access this resource",
      actionLabel: 'Go Back',
      onAction: onAction,
    );
  }

  /// Error state for not found
  static Widget notFound({VoidCallback? onAction}) {
    return ErrorWidgetCustom(
      icon: Icons.find_in_page,
      title: 'Not found',
      message: 'The requested resource could not be found',
      actionLabel: 'Go Back',
      onAction: onAction,
    );
  }
}
