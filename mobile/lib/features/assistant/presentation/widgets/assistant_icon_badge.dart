import 'package:flutter/material.dart';

class AssistantIconBadge extends StatelessWidget {
  const AssistantIconBadge({
    required this.icon,
    super.key,
    this.size = 40,
    this.iconSize = 20,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.tooltip,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final badge = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: borderColor == null
            ? null
            : Border.all(
                color: borderColor!,
              ),
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foregroundColor ?? colorScheme.onPrimaryContainer,
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return badge;
    }

    return Tooltip(
      message: tooltip,
      child: badge,
    );
  }
}
