import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/assistant_repository.dart';
import '../domain/entities/assistant_message.dart';
import '../domain/repositories/assistant_repository.dart';
import '../domain/usecases/send_assistant_message.dart';

class AssistantState {
  const AssistantState({
    this.messages = const <AssistantMessage>[],
    this.isLoading = false,
    this.isInitializing = false,
    this.error,
  });

  final List<AssistantMessage> messages;
  final bool isLoading;
  final bool isInitializing;
  final String? error;

  bool get hasMessages => messages.isNotEmpty;

  bool get hasError => error != null && error!.trim().isNotEmpty;

  AssistantState copyWith({
    List<AssistantMessage>? messages,
    bool? isLoading,
    bool? isInitializing,
    String? error,
    bool clearError = false,
  }) {
    return AssistantState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AssistantController extends StateNotifier<AssistantState> {
  AssistantController({
    required AssistantRepository repository,
    required SendAssistantMessage sendAssistantMessage,
  })  : _repository = repository,
        _sendAssistantMessage = sendAssistantMessage,
        super(const AssistantState()) {
    unawaited(loadConversation());
  }

  final AssistantRepository _repository;
  final SendAssistantMessage _sendAssistantMessage;

  static const Uuid _uuid = Uuid();

  Future<void> loadConversation() async {
    if (state.isInitializing) {
      return;
    }

    state = state.copyWith(
      isInitializing: true,
      clearError: true,
    );

    try {
      final messages = await _repository.getConversation();

      state = state.copyWith(
        messages: messages,
        isInitializing: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isInitializing: false,
        error: error.toString(),
      );
    }
  }

  Future<void> sendMessage(String message) async {
    final normalizedMessage = message.trim();

    if (normalizedMessage.isEmpty || state.isLoading) {
      return;
    }

    final userMessage = AssistantMessage(
      id: _uuid.v4(),
      content: normalizedMessage,
      role: AssistantMessageRole.user,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      messages: <AssistantMessage>[
        ...state.messages,
        userMessage,
      ],
      isLoading: true,
      clearError: true,
    );

    try {
      final assistantMessage = await _sendAssistantMessage(
        message: normalizedMessage,
      );

      state = state.copyWith(
        messages: <AssistantMessage>[
          ...state.messages,
          assistantMessage,
        ],
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      final failureMessage = AssistantMessage(
        id: _uuid.v4(),
        content: 'I couldn’t process that request. Please try again.',
        role: AssistantMessageRole.assistant,
        createdAt: DateTime.now(),
        isError: true,
      );

      state = state.copyWith(
        messages: <AssistantMessage>[
          ...state.messages,
          failureMessage,
        ],
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> clearConversation() async {
    if (state.isLoading) {
      return;
    }

    try {
      await _repository.clearConversation();
      state = const AssistantState();
    } catch (error) {
      state = state.copyWith(
        error: error.toString(),
      );
    }
  }

  Future<void> retryLastUserMessage() async {
    if (state.isLoading) {
      return;
    }

    AssistantMessage? lastUserMessage;

    for (final message in state.messages.reversed) {
      if (message.isUser) {
        lastUserMessage = message;
        break;
      }
    }

    if (lastUserMessage == null) {
      return;
    }

    await sendMessage(lastUserMessage.content);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final sendAssistantMessageProvider = Provider<SendAssistantMessage>(
  (ref) {
    final repository = ref.watch(assistantRepositoryProvider);

    return SendAssistantMessage(repository);
  },
  name: 'sendAssistantMessageProvider',
);

final assistantControllerProvider =
    StateNotifierProvider<AssistantController, AssistantState>(
  (ref) {
    final repository = ref.watch(assistantRepositoryProvider);
    final sendAssistantMessage = ref.watch(sendAssistantMessageProvider);

    return AssistantController(
      repository: repository,
      sendAssistantMessage: sendAssistantMessage,
    );
  },
  name: 'assistantControllerProvider',
);
