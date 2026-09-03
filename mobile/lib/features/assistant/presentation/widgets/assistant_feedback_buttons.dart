import 'package:flutter/material.dart';

class AssistantFeedbackButtons extends StatelessWidget {
  const AssistantFeedbackButtons({
    super.key,
    this.onHelpful,
    this.onNotHelpful,
    this.onCopy,
    this.helpfulSelected = false,
    this.notHelpfulSelected = false,
    this.showCopy = true,
  });

  final VoidCallback? onHelpful;
  final VoidCallback? onNotHelpful;
  final VoidCallback? onCopy;

  final bool helpfulSelected;
  final bool notHelpfulSelected;
  final bool showCopy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        _FeedbackButton(
          tooltip: 'Helpful',
          icon: helpfulSelected
              ? Icons.thumb_up_rounded
              : Icons.thumb_up_outlined,
          selected: helpfulSelected,
          onPressed: onHelpful,
        ),
        _FeedbackButton(
          tooltip: 'Not helpful',
          icon: notHelpfulSelected
              ? Icons.thumb_down_rounded
              : Icons.thumb_down_outlined,
          selected: notHelpfulSelected,
          onPressed: onNotHelpful,
        ),
        if (showCopy)
          _FeedbackButton(
            tooltip: 'Copy response',
            icon: Icons.content_copy_rounded,
            selected: false,
            onPressed: onCopy,
          ),
      ],
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        style: IconButton.styleFrom(
          foregroundColor:
              selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
          backgroundColor:
              selected ? colorScheme.primaryContainer : Colors.transparent,
        ),
        icon: Icon(icon),
      ),
    );
  }
}
