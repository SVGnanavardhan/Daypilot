import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Loading widget for displaying loading states.
///
/// This widget provides different loading indicators for various scenarios.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    this.message,
    this.isFullScreen = false,
  });

  final String? message;
  final bool isFullScreen;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );

    if (isFullScreen) {
      return Scaffold(
        body: content,
      );
    }

    return content;
  }
}

/// Shimmer loading widget for skeleton screens.
///
/// This widget provides a shimmer effect for placeholder content
/// while data is being loaded.
class ShimmerLoadingWidget extends StatelessWidget {
  const ShimmerLoadingWidget({
    required this.child,
    super.key,
    this.baseColor,
    this.highlightColor,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey[300]!,
      highlightColor: highlightColor ?? Colors.grey[100]!,
      child: child,
    );
  }
}

/// Card shimmer placeholder.
class CardShimmer extends StatelessWidget {
  const CardShimmer({
    super.key,
    this.height = 100,
    this.width = double.infinity,
  });

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoadingWidget(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

/// List shimmer placeholder.
class ListShimmer extends StatelessWidget {
  const ListShimmer({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: CardShimmer(height: 80),
        );
      },
    );
  }
}

/// Circular button loading widget.
class ButtonLoadingWidget extends StatelessWidget {
  const ButtonLoadingWidget({
    super.key,
    this.color,
    this.size = 20,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
