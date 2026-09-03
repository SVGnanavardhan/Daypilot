import 'package:flutter/material.dart';

enum AssistantActionResultType {
  success,
  warning,
  error,
  info,
}

class AssistantActionResultCard extends StatelessWidget {
  const AssistantActionResultCard({
    required this.title,
    required this.message,
    super.key,
    this.type = AssistantActionResultType.success,
    this.actionLabel,
    this.onAction,
    this.details = const <String>[],
  });

  final String title;
  final String message;
  final AssistantActionResultType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final colors = _resolveColors(colorScheme);

    final hasAction = actionLabel != null &&
        actionLabel!.trim().isNotEmpty &&
        onAction != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.foreground.withValues(
            alpha: 0.2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                _icon,
                size: 22,
                color: colors.foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.foreground,
              height: 1.4,
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...details.map(
              (detail) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 6,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: colors.foreground,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        detail,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.foreground,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    );
  }

  IconData get _icon {
    switch (type) {
      case AssistantActionResultType.success:
        return Icons.check_circle_outline_rounded;
      case AssistantActionResultType.warning:
        return Icons.warning_amber_rounded;
      case AssistantActionResultType.error:
        return Icons.error_outline_rounded;
      case AssistantActionResultType.info:
        return Icons.info_outline_rounded;
    }
  }

  _ActionResultColors _resolveColors(
    ColorScheme colorScheme,
  ) {
    switch (type) {
      case AssistantActionResultType.success:
        return _ActionResultColors(
          background: colorScheme.secondaryContainer,
          foreground: colorScheme.onSecondaryContainer,
        );

      case AssistantActionResultType.warning:
        return _ActionResultColors(
          background: colorScheme.tertiaryContainer,
          foreground: colorScheme.onTertiaryContainer,
        );

      case AssistantActionResultType.error:
        return _ActionResultColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
        );

      case AssistantActionResultType.info:
        return _ActionResultColors(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
        );
    }
  }
}

class _ActionResultColors {
  const _ActionResultColors({
    required this.background,
    required this.foreground,
  });

  final Color background;
  final Color foreground;
}
