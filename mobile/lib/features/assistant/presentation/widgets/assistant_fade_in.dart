import 'package:flutter/material.dart';

class AssistantFadeIn extends StatelessWidget {
  const AssistantFadeIn({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 250),
    this.visible = true,
  });

  final Widget child;
  final Duration duration;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: duration,
      curve: Curves.easeOut,
      child: child,
    );
  }
}
