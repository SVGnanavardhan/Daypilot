import 'package:flutter/material.dart';

class AssistantCapabilityChip extends StatelessWidget {
  const AssistantCapabilityChip({
    required this.label,
    required this.icon,
    super.key,
    this.description,
    this.isEnabled = true,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String? description;
  final bool isEnabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foregroundColor = isEnabled
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

    final backgroundColor = isEnabled
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;

    final chip = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: foregroundColor,
              ),
              const SizedBox(width: 7),
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
              if (!isEnabled) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: foregroundColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (description == null || description!.trim().isEmpty) {
      return chip;
    }

    return Tooltip(
      message: description,
      child: chip,
    );
  }
}
