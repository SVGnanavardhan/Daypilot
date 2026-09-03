import 'package:flutter/material.dart';

class AssistantScaffold extends StatelessWidget {
  const AssistantScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.header,
    this.bottom,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  final PreferredSizeWidget? appBar;
  final Widget? header;
  final Widget body;
  final Widget? bottom;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      body: Column(
        children: [
          if (header != null) header!,
          Expanded(
            child: body,
          ),
          if (bottom != null) bottom!,
        ],
      ),
    );
  }
}
