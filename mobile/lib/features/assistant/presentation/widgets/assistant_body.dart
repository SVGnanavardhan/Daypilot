import 'package:flutter/material.dart';

class AssistantBody extends StatelessWidget {
  const AssistantBody({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.backgroundColor,
    this.scrollController,
    this.isScrollable = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final ScrollController? scrollController;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
      padding: padding,
      child: child,
    );

    return ColoredBox(
      color: backgroundColor ?? colorScheme.surface,
      child: isScrollable
          ? SingleChildScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: content,
            )
          : content,
    );
  }
}
