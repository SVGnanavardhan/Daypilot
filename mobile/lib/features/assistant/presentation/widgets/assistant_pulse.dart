import 'dart:async';

import 'package:flutter/material.dart';

class AssistantPulse extends StatefulWidget {
  const AssistantPulse({
    required this.child,
    super.key,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 1200),
    this.minScale = 0.96,
  });

  final Widget child;
  final bool enabled;
  final Duration duration;
  final double minScale;

  @override
  State<AssistantPulse> createState() => _AssistantPulseState();
}

class _AssistantPulseState extends State<AssistantPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _configureAnimation();

    if (widget.enabled) {
      unawaited(
        _controller.repeat(
          reverse: true,
        ),
      );
    }
  }

  void _configureAnimation() {
    _animation = Tween<double>(
      begin: widget.minScale,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant AssistantPulse oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.minScale != widget.minScale) {
      _configureAnimation();
    }

    if (oldWidget.enabled != widget.enabled) {
      if (widget.enabled) {
        unawaited(
          _controller.repeat(
            reverse: true,
          ),
        );
      } else {
        _controller
          ..stop()
          ..value = 1;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}
