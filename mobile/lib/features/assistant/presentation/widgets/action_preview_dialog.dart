import 'package:flutter/material.dart';

class ActionPreviewDialog extends StatelessWidget {
  const ActionPreviewDialog({
    required this.title,
    required this.description,
    required this.onConfirm,
    super.key,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.icon = Icons.auto_awesome_rounded,
    this.details = const <ActionPreviewDetail>[],
    this.isDestructive = false,
  });

  final String title;
  final String description;
  final VoidCallback onConfirm;

  final String confirmLabel;
  final String cancelLabel;
  final IconData icon;

  final List<ActionPreviewDetail> details;

  final bool isDestructive;

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String description,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    IconData icon = Icons.auto_awesome_rounded,
    List<ActionPreviewDetail> details = const <ActionPreviewDetail>[],
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ActionPreviewDialog(
          title: title,
          description: description,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          icon: icon,
          details: details,
          isDestructive: isDestructive,
          onConfirm: () {
            Navigator.of(dialogContext).pop(true);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final actionColor = isDestructive ? colorScheme.error : colorScheme.primary;

    return AlertDialog(
      icon: Icon(
        icon,
        color: actionColor,
        size: 30,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 420,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < details.length; index++) ...[
                        _ActionPreviewDetailRow(
                          detail: details[index],
                        ),
                        if (index != details.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Divider(height: 1),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: Text(cancelLabel),
        ),
        FilledButton(
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                )
              : null,
          onPressed: onConfirm,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _ActionPreviewDetailRow extends StatelessWidget {
  const _ActionPreviewDetailRow({
    required this.detail,
  });

  final ActionPreviewDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (detail.icon != null) ...[
          Icon(
            detail.icon,
            size: 18,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                detail.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                detail.value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ActionPreviewDetail {
  const ActionPreviewDetail({
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final IconData? icon;
}
