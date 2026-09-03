import 'package:flutter/material.dart';

class AssistantInputHelper extends StatelessWidget {
  const AssistantInputHelper({
    super.key,
    this.message =
        'AI can make mistakes. Review important actions before confirming.',
    this.icon = Icons.info_outline_rounded,
    this.trailing,
    this.showIcon = true,
  });

  final String message;
  final IconData icon;
  final Widget? trailing;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (message.trim().isEmpty && trailing == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        if (showIcon && message.trim().isNotEmpty) ...[
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
        ],
        if (message.trim().isNotEmpty)
          Expanded(
            child: Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
            ),
          )
        else
          const Spacer(),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}
