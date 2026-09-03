import 'package:flutter/material.dart';

class AssistantSidebarList extends StatelessWidget {
  const AssistantSidebarList({
    required this.children,
    super.key,
    this.spacing = 6,
    this.padding = EdgeInsets.zero,
    this.shrinkWrap = true,
    this.physics = const NeverScrollableScrollPhysics(),
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(
        height: spacing,
      ),
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}
