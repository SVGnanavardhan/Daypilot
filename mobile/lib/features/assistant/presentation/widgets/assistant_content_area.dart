import 'package:flutter/material.dart';

class AssistantContentArea extends StatelessWidget {
  const AssistantContentArea({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.maxWidth = 760,
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: backgroundColor ?? colorScheme.surface,
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          child: Padding(
            padding: padding,
            child: SizedBox(
              width: double.infinity,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
