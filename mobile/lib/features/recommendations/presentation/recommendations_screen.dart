import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'recommendation_controller.dart';
import 'widgets/recommendation_card.dart';
import 'widgets/recommendation_empty_state.dart';

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      recommendationControllerProvider,
    );

    final controller = ref.read(
      recommendationControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommendations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isLoading ? null : controller.refresh,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(
          context,
          state,
          controller,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    RecommendationState state,
    RecommendationController controller,
  ) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      return _RecommendationErrorView(
        message: state.error!,
        onRetry: controller.refresh,
      );
    }

    if (state.items.isEmpty) {
      return RecommendationEmptyState(
        onRefresh: controller.refresh,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (
          context,
          index,
        ) {
          final recommendation = state.items[index];

          return RecommendationCard(
            recommendation: recommendation,
            onAccept: () {
              unawaited(
                controller.accept(
                  recommendation.id,
                ),
              );
            },
            onDismiss: () {
              unawaited(
                controller.dismiss(
                  recommendation.id,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RecommendationErrorView extends StatelessWidget {
  const _RecommendationErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load recommendations',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
