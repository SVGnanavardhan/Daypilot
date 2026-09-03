import 'package:flutter/material.dart';

class AssistantResponseActions extends StatelessWidget {
  const AssistantResponseActions({
    super.key,
    this.onCopy,
    this.onRetry,
    this.onLike,
    this.onDislike,
  });

  final VoidCallback? onCopy;
  final VoidCallback? onRetry;
  final VoidCallback? onLike;
  final VoidCallback? onDislike;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 4,
      children: [
        if (onCopy != null)
          IconButton(
            tooltip: 'Copy',
            visualDensity: VisualDensity.compact,
            onPressed: onCopy,
            icon: const Icon(
              Icons.copy_outlined,
              size: 18,
            ),
          ),
        if (onRetry != null)
          IconButton(
            tooltip: 'Regenerate',
            visualDensity: VisualDensity.compact,
            onPressed: onRetry,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 19,
            ),
          ),
        if (onLike != null)
          IconButton(
            tooltip: 'Helpful',
            visualDensity: VisualDensity.compact,
            onPressed: onLike,
            icon: const Icon(
              Icons.thumb_up_alt_outlined,
              size: 18,
            ),
          ),
        if (onDislike != null)
          IconButton(
            tooltip: 'Not helpful',
            visualDensity: VisualDensity.compact,
            onPressed: onDislike,
            icon: Icon(
              Icons.thumb_down_alt_outlined,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
