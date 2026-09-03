import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'focus_controller.dart';
import 'widgets/focus_timer.dart';

class FocusScreen extends ConsumerWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(focusControllerProvider);
    final controller = ref.read(focusControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Focus Session',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Stay focused on one task at a time.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            FocusTimer(
              remainingSeconds: state.remainingSeconds,
              isRunning: state.isRunning,
              onStart: controller.start,
              onPause: controller.pause,
              onReset: controller.reset,
            ),
            const SizedBox(height: 24),
            Text(
              'Session length',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [15, 25, 45, 60]
                  .map(
                    (minutes) => ChoiceChip(
                      label: Text('$minutes min'),
                      selected: state.durationMinutes == minutes,
                      onSelected: state.isRunning
                          ? null
                          : (_) => controller.setDuration(minutes),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.insights_outlined,
                ),
                title: const Text(
                  'Total completed focus time',
                ),
                trailing: Text(
                  '${state.totalFocusMinutes} min',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            if (state.isCompleted) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Focus session completed. Great work!',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
