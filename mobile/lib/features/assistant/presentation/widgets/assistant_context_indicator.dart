import 'package:flutter/material.dart';

class AssistantContextIndicator extends StatelessWidget {
  const AssistantContextIndicator({
    required this.label,
    super.key,
    this.icon = Icons.memory_rounded,
    this.description,
    this.isActive = true,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String? description;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foregroundColor =
        isActive ? colorScheme.primary : colorScheme.onSurfaceVariant;

    final backgroundColor = isActive
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;

    final content = Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
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
              const SizedBox(width: 6),
              Icon(
                isActive ? Icons.circle_rounded : Icons.circle_outlined,
                size: 9,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );

    if (description == null || description!.trim().isEmpty) {
      return content;
    }

    return Tooltip(
      message: description,
      child: content,
    );
  }
}
