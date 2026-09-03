import 'package:flutter/material.dart';

class AssistantTabletLayout extends StatelessWidget {
  const AssistantTabletLayout({
    required this.content,
    super.key,
    this.sidebar,
    this.sidebarWidth = 240,
    this.showSidebar = true,
  });

  final Widget content;
  final Widget? sidebar;
  final double sidebarWidth;
  final bool showSidebar;

  @override
  Widget build(BuildContext context) {
    if (!showSidebar || sidebar == null) {
      return content;
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        SizedBox(
          width: sidebarWidth,
          child: sidebar,
        ),
        Container(
          width: 1,
          color: colorScheme.outlineVariant,
        ),
        Expanded(
          child: content,
        ),
      ],
    );
  }
}
