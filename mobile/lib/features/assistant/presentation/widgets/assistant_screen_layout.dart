import 'package:flutter/material.dart';

class AssistantScreenLayout extends StatelessWidget {
  const AssistantScreenLayout({
    required this.body,
    super.key,
    this.header,
    this.bottom,
    this.floatingActionButton,
    this.backgroundColor,
    this.maxWidth = 900,
  });

  final Widget body;
  final Widget? header;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Column(
              children: [
                if (header != null) header!,
                Expanded(
                  child: body,
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
