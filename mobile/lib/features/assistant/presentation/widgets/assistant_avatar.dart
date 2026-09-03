import 'package:flutter/material.dart';

class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({
    super.key,
    this.size = 36,
    this.icon = Icons.auto_awesome_rounded,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip = 'DayPilot Assistant',
  });

  final double size;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? colorScheme.primaryContainer,
      ),
      child: Icon(
        icon,
        size: size * 0.5,
        color: foregroundColor ?? colorScheme.onPrimaryContainer,
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return avatar;
    }

    return Tooltip(
      message: tooltip,
      child: avatar,
    );
  }
}
