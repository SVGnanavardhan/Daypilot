import 'package:flutter/material.dart';

class AssistantKeyboardDismissArea extends StatelessWidget {
  const AssistantKeyboardDismissArea({
    required this.child,
    super.key,
    this.behavior = HitTestBehavior.translucent,
  });

  final Widget child;
  final HitTestBehavior behavior;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: behavior,
      onTap: () {
        final focusScope = FocusScope.of(context);

        if (!focusScope.hasPrimaryFocus) {
          focusScope.unfocus();
        }
      },
      child: child,
    );
  }
}
