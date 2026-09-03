import 'package:flutter/material.dart';

class AssistantInputContainer extends StatelessWidget {
  const AssistantInputContainer({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.fromLTRB(12, 10, 12, 12),
    this.backgroundColor,
    this.showTopBorder = true,
    this.safeBottom = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showTopBorder;
  final bool safeBottom;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: showTopBorder
            ? Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant,
                ),
              )
            : null,
      ),
      child: child,
    );

    if (!safeBottom) {
      return content;
    }

    return SafeArea(
      top: false,
      child: content,
    );
  }
}
