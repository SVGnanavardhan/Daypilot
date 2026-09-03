import 'package:flutter/material.dart';

class FocusTimer extends StatelessWidget {
  const FocusTimer({
    required this.remainingSeconds,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    super.key,
  });

  final int remainingSeconds;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final minutes = remainingSeconds ~/ 60;

    final seconds = remainingSeconds % 60;

    final time = '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 32,
        ),
        child: Column(
          children: [
            Icon(
              Icons.timer_outlined,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              time,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: isRunning ? onPause : onStart,
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                  ),
                  label: Text(
                    isRunning ? 'Pause' : 'Start',
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onReset,
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
