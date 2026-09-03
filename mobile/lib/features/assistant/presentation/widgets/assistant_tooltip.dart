import 'package:flutter/material.dart';

class AssistantTooltip extends StatelessWidget {
  const AssistantTooltip({
    required this.message,
    required this.child,
    super.key,
    this.waitDuration = const Duration(milliseconds: 400),
  });

  final String message;
  final Widget child;
  final Duration waitDuration;

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) {
      return child;
    }

    return Tooltip(
      message: message,
      waitDuration: waitDuration,
      child: child,
    );
  }
}
