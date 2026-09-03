import 'package:flutter/material.dart';

class AssistantSlideIn extends StatelessWidget {
  const AssistantSlideIn({
    required this.child,
    super.key,
    this.visible = true,
    this.duration = const Duration(milliseconds: 250),
    this.beginOffset = const Offset(0, 0.08),
  });

  final Widget child;
  final bool visible;
  final Duration duration;
  final Offset beginOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : beginOffset,
      duration: duration,
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: duration,
        curve: Curves.easeOut,
        child: child,
      ),
    );
  }
}
