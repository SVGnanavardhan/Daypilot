import 'package:flutter/material.dart';

class AssistantMessageActions extends StatelessWidget {
  const AssistantMessageActions({
    super.key,
    this.onCopy,
    this.onRetry,
    this.onHelpful,
    this.onNotHelpful,
    this.showCopy = true,
    this.showRetry = false,
    this.showFeedback = true,
  });

  final VoidCallback? onCopy;
  final VoidCallback? onRetry;
  final VoidCallback? onHelpful;
  final VoidCallback? onNotHelpful;

  final bool showCopy;
  final bool showRetry;
  final bool showFeedback;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 2,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (showCopy)
          _MessageActionButton(
            tooltip: 'Copy',
            icon: Icons.content_copy_rounded,
            onPressed: onCopy,
            color: colorScheme.onSurfaceVariant,
          ),
        if (showRetry)
          _MessageActionButton(
            tooltip: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
            color: colorScheme.onSurfaceVariant,
          ),
        if (showFeedback) ...[
          _MessageActionButton(
            tooltip: 'Helpful',
            icon: Icons.thumb_up_outlined,
            onPressed: onHelpful,
            color: colorScheme.onSurfaceVariant,
          ),
          _MessageActionButton(
            tooltip: 'Not helpful',
            icon: Icons.thumb_down_outlined,
            onPressed: onNotHelpful,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }
}

class _MessageActionButton extends StatelessWidget {
  const _MessageActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        iconSize: 17,
        color: color,
        icon: Icon(icon),
      ),
    );
  }
}
