import 'package:flutter/material.dart';

Future<bool> showAssistantConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      final theme = Theme.of(dialogContext);
      final colorScheme = theme.colorScheme;

      return AlertDialog(
        icon: Icon(
          isDestructive
              ? Icons.warning_amber_rounded
              : Icons.auto_awesome_rounded,
          color: isDestructive ? colorScheme.error : colorScheme.primary,
        ),
        title: Text(title),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: Text(cancelText),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  )
                : null,
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: Text(confirmText),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
