import 'package:flutter/material.dart';

class AssistantAnimatedVisibility extends StatelessWidget {
  const AssistantAnimatedVisibility({
    required this.visible,
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 200),
  });

  final bool visible;
  final Widget child;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: visible
          ? KeyedSubtree(
              key: const ValueKey('visible'),
              child: child,
            )
          : const SizedBox.shrink(
              key: ValueKey('hidden'),
            ),
    );
  }
}
