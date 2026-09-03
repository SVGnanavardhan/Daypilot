import 'dart:async';

import 'package:flutter/material.dart';

class AssistantShimmerPlaceholder extends StatefulWidget {
  const AssistantShimmerPlaceholder({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 16,
    this.duration = const Duration(milliseconds: 1200),
  });

  final double height;
  final double width;
  final double borderRadius;
  final Duration duration;

  @override
  State<AssistantShimmerPlaceholder> createState() =>
      _AssistantShimmerPlaceholderState();
}

class _AssistantShimmerPlaceholderState
    extends State<AssistantShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    unawaited(
      _controller.repeat(),
    );
  }

  @override
  void didUpdateWidget(
    covariant AssistantShimmerPlaceholder oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;

      unawaited(
        _controller.repeat(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                widget.borderRadius,
              ),
              gradient: LinearGradient(
                begin: Alignment(
                  -1.5 + (_controller.value * 3),
                  0,
                ),
                end: Alignment(
                  -0.5 + (_controller.value * 3),
                  0,
                ),
                colors: [
                  colorScheme.surfaceContainerHighest,
                  colorScheme.surfaceContainerLow,
                  colorScheme.surfaceContainerHighest,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
