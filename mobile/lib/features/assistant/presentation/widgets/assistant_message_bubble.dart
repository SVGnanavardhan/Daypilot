import 'package:flutter/material.dart';

import '../../domain/entities/assistant_message.dart';

class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({
    required this.message,
    super.key,
  });

  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isUser = message.isUser;
    final isError = message.isError;

    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;

    final backgroundColor = isError
        ? colorScheme.errorContainer
        : isUser
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest;

    final foregroundColor = isError
        ? colorScheme.onErrorContainer
        : isUser
            ? colorScheme.onPrimary
            : colorScheme.onSurfaceVariant;

    final icon = isError
        ? Icons.error_outline_rounded
        : isUser
            ? Icons.person_outline_rounded
            : Icons.auto_awesome_rounded;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 340,
        ),
        margin: const EdgeInsets.only(
          bottom: 12,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(
              isUser ? 18 : 4,
            ),
            bottomRight: Radius.circular(
              isUser ? 4 : 18,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: foregroundColor,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: SelectableText(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
