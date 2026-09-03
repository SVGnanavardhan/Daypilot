import 'package:flutter/material.dart';

class AssistantMessageGroup extends StatelessWidget {
  const AssistantMessageGroup({
    required this.children,
    super.key,
    this.label,
    this.spacing = 8,
    this.padding = EdgeInsets.zero,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final List<Widget> children;
  final String? label;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasLabel = label != null && label!.trim().isNotEmpty;

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (hasLabel) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: 4,
                bottom: 8,
              ),
              child: Text(
                label!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              SizedBox(
                height: spacing,
              ),
          ],
        ],
      ),
    );
  }
}
