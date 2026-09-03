import 'package:flutter/material.dart';

class AssistantSafeArea extends StatelessWidget {
  const AssistantSafeArea({
    required this.child,
    super.key,
    this.minimum = EdgeInsets.zero,
    this.top = true,
    this.bottom = true,
    this.left = true,
    this.right = true,
    this.maintainBottomViewPadding = false,
  });

  final Widget child;
  final EdgeInsets minimum;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;
  final bool maintainBottomViewPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: minimum,
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      maintainBottomViewPadding: maintainBottomViewPadding,
      child: child,
    );
  }
}
