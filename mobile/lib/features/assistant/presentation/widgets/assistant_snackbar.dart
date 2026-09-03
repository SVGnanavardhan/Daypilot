import 'package:flutter/material.dart';

enum AssistantSnackbarType {
  info,
  success,
  warning,
  error,
}

class AssistantSnackbar {
  const AssistantSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    AssistantSnackbarType type = AssistantSnackbarType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final backgroundColor = switch (type) {
      AssistantSnackbarType.info => colorScheme.inverseSurface,
      AssistantSnackbarType.success => colorScheme.primary,
      AssistantSnackbarType.warning => colorScheme.tertiary,
      AssistantSnackbarType.error => colorScheme.error,
    };

    final foregroundColor = switch (type) {
      AssistantSnackbarType.info => colorScheme.onInverseSurface,
      AssistantSnackbarType.success => colorScheme.onPrimary,
      AssistantSnackbarType.warning => colorScheme.onTertiary,
      AssistantSnackbarType.error => colorScheme.onError,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyle(
              color: foregroundColor,
            ),
          ),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          action: actionLabel != null && onAction != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: foregroundColor,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
