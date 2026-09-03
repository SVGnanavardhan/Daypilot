import 'package:flutter/material.dart';

enum AssistantActionButtonStyle {
  primary,
  secondary,
  text,
  destructive,
}

class AssistantActionButton extends StatelessWidget {
  const AssistantActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.style = AssistantActionButtonStyle.primary,
    this.isLoading = false,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AssistantActionButtonStyle style;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final callback = isLoading ? null : onPressed;

    final Widget child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          )
        : Row(
            mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    Widget button;

    switch (style) {
      case AssistantActionButtonStyle.primary:
        button = FilledButton(
          onPressed: callback,
          child: child,
        );

      case AssistantActionButtonStyle.secondary:
        button = OutlinedButton(
          onPressed: callback,
          child: child,
        );

      case AssistantActionButtonStyle.text:
        button = TextButton(
          onPressed: callback,
          child: child,
        );

      case AssistantActionButtonStyle.destructive:
        button = FilledButton(
          onPressed: callback,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: child,
        );
    }

    if (!isExpanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
