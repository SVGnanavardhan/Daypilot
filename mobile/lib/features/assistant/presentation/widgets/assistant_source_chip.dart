import 'package:flutter/material.dart';

class AssistantSourceChip extends StatelessWidget {
  const AssistantSourceChip({
    required this.label,
    super.key,
    this.icon = Icons.link_rounded,
    this.onTap,
    this.tooltip,
    this.isExternal = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool isExternal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final chip = Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 7,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isExternal) ...[
                const SizedBox(width: 5),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
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
