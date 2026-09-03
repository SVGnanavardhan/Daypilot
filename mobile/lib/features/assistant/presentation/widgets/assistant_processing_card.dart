import 'package:flutter/material.dart';

import 'assistant_processing_step.dart';

class AssistantProcessingStepData {
  const AssistantProcessingStepData({
    required this.title,
    this.subtitle,
    this.status = AssistantProcessingStepStatus.pending,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final AssistantProcessingStepStatus status;
  final VoidCallback? onRetry;
}

class AssistantProcessingCard extends StatelessWidget {
  const AssistantProcessingCard({
    required this.steps,
    super.key,
    this.title = 'Working on it',
    this.subtitle,
    this.showProgress = true,
  });

  final List<AssistantProcessingStepData> steps;
  final String title;
  final String? subtitle;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final completedCount = steps
        .where(
          (step) => step.status == AssistantProcessingStepStatus.completed,
        )
        .length;

    final progress = steps.isEmpty ? 0.0 : completedCount / steps.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          if (showProgress && steps.isNotEmpty) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
          if (steps.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (var index = 0; index < steps.length; index++) ...[
              AssistantProcessingStep(
                title: steps[index].title,
                subtitle: steps[index].subtitle,
                status: steps[index].status,
                onRetry: steps[index].onRetry,
              ),
              if (index < steps.length - 1) const SizedBox(height: 14),
            ],
          ],
        ],
      ),
    );
  }
}
