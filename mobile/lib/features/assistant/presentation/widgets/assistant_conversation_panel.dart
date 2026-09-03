import 'package:flutter/material.dart';

class AssistantConversationPanel extends StatelessWidget {
  const AssistantConversationPanel({
    required this.messages,
    super.key,
    this.header,
    this.input,
    this.scrollController,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.backgroundColor,
  });

  final Widget messages;
  final Widget? header;
  final Widget? input;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
      ),
      child: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: Padding(
              padding: padding,
              child: PrimaryScrollController(
                controller: scrollController ?? ScrollController(),
                child: messages,
              ),
            ),
          ),
          if (input != null) input!,
        ],
      ),
    );
  }
}
