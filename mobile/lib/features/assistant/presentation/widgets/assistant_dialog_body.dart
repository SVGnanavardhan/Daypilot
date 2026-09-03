import 'package:flutter/material.dart';

class AssistantDialogBody extends StatelessWidget {
  const AssistantDialogBody({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      vertical: 12,
    ),
    this.maxWidth = 460,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
