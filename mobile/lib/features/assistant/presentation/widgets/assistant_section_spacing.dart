import 'package:flutter/material.dart';

class AssistantSectionSpacing extends StatelessWidget {
  const AssistantSectionSpacing({
    super.key,
    this.height = 16,
  });

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}
