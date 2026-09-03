import 'package:flutter/material.dart';

class AssistantStatusDot extends StatelessWidget {
  const AssistantStatusDot({
    required this.isActive,
    super.key,
    this.size = 10,
    this.activeColor,
    this.inactiveColor,
    this.tooltip,
  });

  final bool isActive;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? activeColor ?? colorScheme.primary
            : inactiveColor ?? colorScheme.outline,
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return dot;
    }

    return Tooltip(
      message: tooltip,
      child: dot,
    );
  }
}
