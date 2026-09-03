import 'package:flutter/material.dart';

class AssistantSidebar extends StatelessWidget {
  const AssistantSidebar({
    required this.child,
    super.key,
    this.header,
    this.footer,
    this.width = 280,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor,
    this.showDivider = true,
  });

  final Widget child;
  final Widget? header;
  final Widget? footer;
  final double width;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor ?? colorScheme.surfaceContainerLow,
          border: showDivider
              ? Border(
                  right: BorderSide(
                    color: colorScheme.outlineVariant,
                  ),
                )
              : null,
        ),
        child: SafeArea(
          right: false,
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  header!,
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: child,
                ),
                if (footer != null) ...[
                  const SizedBox(height: 16),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
