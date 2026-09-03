import 'package:flutter/material.dart';

class RecommendationLoadingView extends StatelessWidget {
  const RecommendationLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Preparing recommendations...'),
          ],
        ),
      ),
    );
  }
}
