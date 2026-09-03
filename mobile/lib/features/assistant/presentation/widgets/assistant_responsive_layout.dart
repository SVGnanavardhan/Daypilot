import 'package:flutter/material.dart';

class AssistantResponsiveLayout extends StatelessWidget {
  const AssistantResponsiveLayout({
    required this.mobile,
    super.key,
    this.tablet,
    this.desktop,
    this.tabletBreakpoint = 700,
    this.desktopBreakpoint = 1100,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  final double tabletBreakpoint;
  final double desktopBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width >= desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        }

        if (width >= tabletBreakpoint) {
          return tablet ?? mobile;
        }

        return mobile;
      },
    );
  }
}
