import 'package:flutter/material.dart';

class AssistantDesktopLayout extends StatelessWidget {
  const AssistantDesktopLayout({
    required this.sidebar,
    required this.content,
    super.key,
    this.sidebarWidth = 280,
    this.dividerWidth = 1,
  });

  final Widget sidebar;
  final Widget content;
  final double sidebarWidth;
  final double dividerWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: sidebarWidth,
          child: sidebar,
        ),
        Container(
          width: dividerWidth,
          color: colorScheme.outlineVariant,
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }
}
