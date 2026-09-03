import 'package:flutter/material.dart';

enum AssistantNoticeType {
  info,
  success,
  warning,
  error,
}

class AssistantNoticeCard extends StatelessWidget {
  const AssistantNoticeCard({
    required this.message,
    super.key,
    this.title,
    this.type = AssistantNoticeType.info,
    this.actionLabel,
    this.onAction,
  });

  final String? title;
  final String message;
  final AssistantNoticeType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final colors = _resolveColors(colorScheme);
    final icon = _resolveIcon();

    final hasTitle = title != null && title!.trim().isNotEmpty;
    final hasAction = actionLabel != null &&
        actionLabel!.trim().isNotEmpty &&
        onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.foreground.withValues(
            alpha: 0.22,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colors.foreground,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) ...[
                  Text(
                    title!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colors.foreground,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.foreground,
                    height: 1.4,
                  ),
                ),
                if (hasAction) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onAction,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.foreground,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                    ),
                    child: Text(actionLabel!),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _resolveIcon() {
    switch (type) {
      case AssistantNoticeType.info:
        return Icons.info_outline_rounded;
      case AssistantNoticeType.success:
        return Icons.check_circle_outline_rounded;
      case AssistantNoticeType.warning:
        return Icons.warning_amber_rounded;
      case AssistantNoticeType.error:
        return Icons.error_outline_rounded;
    }
  }

  _NoticeColors _resolveColors(ColorScheme colorScheme) {
    switch (type) {
      case AssistantNoticeType.info:
        return _NoticeColors(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        );

      case AssistantNoticeType.success:
        return _NoticeColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
        );

      case AssistantNoticeType.warning:
        return _NoticeColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
        );

      case AssistantNoticeType.error:
        return _NoticeColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
        );
    }
  }
}

class _NoticeColors {
  const _NoticeColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
