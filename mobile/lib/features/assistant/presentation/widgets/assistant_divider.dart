import 'package:flutter/material.dart';

class AssistantDivider extends StatelessWidget {
  const AssistantDivider({
    super.key,
    this.label,
    this.indent = 0,
    this.endIndent = 0,
    this.verticalPadding = 12,
  });

  final String? label;
  final double indent;
  final double endIndent;
  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasLabel = label != null && label!.trim().isNotEmpty;

    if (!hasLabel) {
      return Padding(
        padding: EdgeInsets.symmetric(
          vertical: verticalPadding,
        ),
        child: Divider(
          height: 1,
          thickness: 1,
          indent: indent,
          endIndent: endIndent,
          color: colorScheme.outlineVariant,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              indent: indent,
              color: colorScheme.outlineVariant,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              height: 1,
              thickness: 1,
              endIndent: endIndent,
              color: colorScheme.outlineVariant,
            ),
          ),
        ],
      ),
    );
  }
}
