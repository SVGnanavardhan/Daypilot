import 'package:flutter/material.dart';

class AssistantMobileLayout extends StatelessWidget {
  const AssistantMobileLayout({
    required this.content,
    super.key,
    this.header,
    this.bottom,
  });

  final Widget content;
  final Widget? header;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (header != null) header!,
        Expanded(
          child: content,
        ),
        if (bottom != null) bottom!,
      ],
    );
  }
}
