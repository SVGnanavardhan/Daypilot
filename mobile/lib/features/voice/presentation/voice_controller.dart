import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/voice_service.dart';

class VoiceState {
  const VoiceState({
    this.status = VoiceServiceStatus.idle,
    this.recognizedText = '',
    this.isInitialized = false,
    this.error,
  });

  final VoiceServiceStatus status;
  final String recognizedText;
  final bool isInitialized;
  final String? error;

  bool get isListening => status == VoiceServiceStatus.listening;

  VoiceState copyWith({
    VoiceServiceStatus? status,
    String? recognizedText,
    bool? isInitialized,
    String? error,
    bool clearError = false,
  }) {
    return VoiceState(
      status: status ?? this.status,
      recognizedText: recognizedText ?? this.recognizedText,
      isInitialized: isInitialized ?? this.isInitialized,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class VoiceController extends StateNotifier<VoiceState> {
  VoiceController({
    required VoiceService service,
  })  : _service = service,
        super(const VoiceState()) {
    unawaited(initialize());
  }

  final VoiceService _service;

  Future<void> initialize() async {
    try {
      final initialized = await _service.initialize();

      state = state.copyWith(
        isInitialized: initialized,
        status: _service.status,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        status: VoiceServiceStatus.unavailable,
        error: error.toString(),
      );
    }
  }

  Future<void> startListening() async {
    if (!state.isInitialized || state.isListening) {
      return;
    }

    try {
      state = state.copyWith(
        status: VoiceServiceStatus.listening,
        clearError: true,
      );

      await _service.startListening(
        onResult: (result) {
          state = state.copyWith(
            recognizedText: result.text,
            status: result.isFinal
                ? VoiceServiceStatus.idle
                : VoiceServiceStatus.listening,
          );
        },
      );
    } catch (error) {
      state = state.copyWith(
        status: VoiceServiceStatus.idle,
        error: error.toString(),
      );
    }
  }

  Future<void> stopListening() async {
    try {
      await _service.stopListening();

      state = state.copyWith(
        status: _service.status,
      );
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
      );
    }
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> cancel() async {
    await _service.cancel();

    state = state.copyWith(
      status: VoiceServiceStatus.idle,
      recognizedText: '',
      clearError: true,
    );
  }

  void clearText() {
    state = state.copyWith(
      recognizedText: '',
      clearError: true,
    );
  }
}

final voiceServiceProvider = Provider<VoiceService>(
  (ref) => LocalVoiceService(),
);

final voiceControllerProvider =
    StateNotifierProvider<VoiceController, VoiceState>(
  (ref) => VoiceController(
    service: ref.watch(voiceServiceProvider),
  ),
);
