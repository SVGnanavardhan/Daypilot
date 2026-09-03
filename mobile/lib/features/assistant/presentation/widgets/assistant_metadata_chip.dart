import 'package:flutter/material.dart';

class AssistantMetadataChip extends StatelessWidget {
  const AssistantMetadataChip({
    required this.label,
    super.key,
    this.icon,
    this.tooltip,
    this.onTap,
    this.isHighlighted = false,
  });

  final String label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback? onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final backgroundColor = isHighlighted
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final foregroundColor = isHighlighted
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurfaceVariant;

    final chip = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: foregroundColor,
                ),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return chip;
    }

    return Tooltip(
      message: tooltip,
      child: chip,
    );
  }
}
