import 'package:flutter/material.dart';

/// Central responsive-layout utilities for DayPilot.
///
/// Breakpoints:
/// - Mobile: < 600
/// - Tablet: 600–1199
/// - Desktop: >= 1200
class ResponsiveUtils {
  ResponsiveUtils._();

  static const double mobileBreakpoint = 600;
  static const double desktopBreakpoint = 1200;

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);

    return width >= mobileBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= desktopBreakpoint;
  }

  /// Returns a value appropriate for the current screen size.
  static T responsiveValue<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    if (isTablet(context)) {
      return tablet ?? mobile;
    }

    return mobile;
  }

  static double responsiveFontSize(
    BuildContext context,
    double mobileSize,
  ) {
    return responsiveValue<double>(
      context: context,
      mobile: mobileSize,
      tablet: mobileSize * 1.1,
      desktop: mobileSize * 1.2,
    );
  }

  static EdgeInsets responsivePadding(BuildContext context) {
    return responsiveValue<EdgeInsets>(
      context: context,
      mobile: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      tablet: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 24,
      ),
      desktop: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 32,
      ),
    );
  }

  static double responsiveSpacing(
    BuildContext context,
    double spacing,
  ) {
    return responsiveValue<double>(
      context: context,
      mobile: spacing,
      tablet: spacing * 1.2,
      desktop: spacing * 1.5,
    );
  }

  /// Calculates an appropriate number of grid columns.
  static int responsiveColumns(
    BuildContext context, {
    int maxColumns = 4,
  }) {
    final width = screenWidth(context);

    if (width >= 1200) {
      return maxColumns;
    }

    if (width >= 900) {
      return (maxColumns * 0.75).round().clamp(1, maxColumns);
    }

    if (width >= 600) {
      return (maxColumns * 0.5).round().clamp(1, maxColumns);
    }

    return 1;
  }

  /// Calculates card width for responsive grid layouts.
  static double responsiveCardWidth(
    BuildContext context, {
    double spacing = 16,
    int maxColumns = 4,
  }) {
    final width = screenWidth(context);

    final columns = responsiveColumns(
      context,
      maxColumns: maxColumns,
    );

    final horizontalPadding = responsivePadding(context).horizontal;

    final totalSpacing = spacing * (columns - 1);

    return (width - horizontalPadding - totalSpacing) / columns;
  }
}

/// Convenient responsive helpers directly on BuildContext.
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);

  bool get isTablet => ResponsiveUtils.isTablet(this);

  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    return ResponsiveUtils.responsiveValue<T>(
      context: this,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
}
