import 'package:flutter/material.dart';

class AssistantSendButton extends StatelessWidget {
  const AssistantSendButton({
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.enabled = true,
    this.tooltip = 'Send message',
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final callback = enabled && !isLoading ? onPressed : null;

    return Tooltip(
      message: tooltip,
      child: IconButton.filled(
        onPressed: callback,
        icon: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : const Icon(
                Icons.arrow_upward_rounded,
              ),
      ),
    );
  }
}
