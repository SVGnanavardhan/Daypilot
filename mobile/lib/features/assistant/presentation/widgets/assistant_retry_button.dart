import 'package:flutter/material.dart';

class AssistantRetryButton extends StatelessWidget {
  const AssistantRetryButton({
    required this.onPressed,
    super.key,
    this.label = 'Try again',
    this.isLoading = false,
    this.compact = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final callback = isLoading ? null : onPressed;

    if (compact) {
      return TextButton.icon(
        onPressed: callback,
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : const Icon(
                Icons.refresh_rounded,
                size: 18,
              ),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: callback,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(
              Icons.refresh_rounded,
              size: 18,
            ),
      label: Text(label),
    );
  }
}
