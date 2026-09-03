import 'package:flutter/material.dart';

class AssistantSidebarDivider extends StatelessWidget {
  const AssistantSidebarDivider({
    super.key,
    this.verticalPadding = 8,
  });

  final double verticalPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
      ),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant,
      ),
    );
  }
}
