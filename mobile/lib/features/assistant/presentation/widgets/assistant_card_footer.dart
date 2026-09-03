import 'package:flutter/material.dart';

class AssistantCardFooter extends StatelessWidget {
  const AssistantCardFooter({
    super.key,
    this.leading,
    this.actions = const <Widget>[],
    this.padding = const EdgeInsets.only(top: 12),
    this.alignment = MainAxisAlignment.end,
    this.spacing = 8,
  });

  final Widget? leading;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;
  final MainAxisAlignment alignment;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (leading == null && actions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: leading,
              ),
            )
          else if (alignment == MainAxisAlignment.end)
            const Spacer(),
          if (actions.isNotEmpty)
            Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
        ],
      ),
    );
  }
}
