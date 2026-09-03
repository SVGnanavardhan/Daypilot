import 'package:flutter/material.dart';

class AssistantScrollToBottomButton extends StatelessWidget {
  const AssistantScrollToBottomButton({
    required this.onPressed,
    super.key,
    this.hasUnreadMessages = false,
    this.tooltip = 'Scroll to latest message',
  });

  final VoidCallback? onPressed;
  final bool hasUnreadMessages;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: colorScheme.surfaceContainerHigh,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                ),
                color: colorScheme.onSurface,
              ),
            ),
            if (hasUnreadMessages)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
