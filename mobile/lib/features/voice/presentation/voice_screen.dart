import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'voice_controller.dart';

class VoiceScreen extends ConsumerWidget {
  const VoiceScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(voiceControllerProvider);

    final controller = ref.read(
      voiceControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Assistant'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: state.isListening
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  state.isListening
                      ? Icons.mic_rounded
                      : Icons.mic_none_rounded,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                state.isListening
                    ? 'Listening...'
                    : 'Tap the microphone to speak',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (state.recognizedText.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.record_voice_over_outlined,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.recognizedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed:
                    state.isInitialized ? controller.toggleListening : null,
                icon: Icon(
                  state.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                ),
                label: Text(
                  state.isListening ? 'Stop Listening' : 'Start Listening',
                ),
              ),
              if (state.recognizedText.isNotEmpty) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: controller.clearText,
                  child: const Text('Clear Text'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
