import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/entities/assistant_message.dart';
import '../domain/repositories/assistant_repository.dart' as domain;

class AssistantRepositoryImpl implements domain.AssistantRepository {
  AssistantRepositoryImpl();

  static const Uuid _uuid = Uuid();

  final List<AssistantMessage> _conversation = <AssistantMessage>[];

  @override
  Future<AssistantMessage> sendMessage({
    required String message,
  }) async {
    final normalizedMessage = message.trim();

    if (normalizedMessage.isEmpty) {
      throw ArgumentError(
        'Assistant message cannot be empty.',
      );
    }

    final userMessage = AssistantMessage(
      id: _uuid.v4(),
      content: normalizedMessage,
      role: AssistantMessageRole.user,
      createdAt: DateTime.now(),
    );

    _conversation.add(userMessage);

    /*
     * Integration boundary
     * --------------------
     * Replace this response generation with the production
     * DayPilot AI backend / Supabase Edge Function when that
     * service is connected.
     *
     * Keeping this boundary inside the repository means the
     * controller and UI will not need to change later.
     */

    final assistantMessage = AssistantMessage(
      id: _uuid.v4(),
      content: _createLocalResponse(normalizedMessage),
      role: AssistantMessageRole.assistant,
      createdAt: DateTime.now(),
    );

    _conversation.add(assistantMessage);

    return assistantMessage;
  }

  @override
  Future<void> clearConversation() async {
    _conversation.clear();
  }

  @override
  Future<List<AssistantMessage>> getConversation() async {
    return List<AssistantMessage>.unmodifiable(
      _conversation,
    );
  }

  String _createLocalResponse(String message) {
    final normalized = message.toLowerCase();

    if (normalized.contains('plan') && normalized.contains('day')) {
      return 'I can help structure your day around your tasks, '
          'schedule, priorities, and available focus time.';
    }

    if (normalized.contains('task') || normalized.contains('priority')) {
      return 'I can help identify your highest-priority task '
          'using urgency, importance, deadlines, and available time.';
    }

    if (normalized.contains('schedule') || normalized.contains('time')) {
      return 'I can help review your schedule and identify suitable '
          'free slots for focused work.';
    }

    if (normalized.contains('productiv')) {
      return 'A strong starting point is to choose one important '
          'task, protect a focused time block, and reduce context switching.';
    }

    return 'I understood your request. DayPilot Assistant is ready '
        'to use your tasks, schedule, and planning context as the '
        'AI backend integration is connected.';
  }
}

final assistantRepositoryProvider = Provider<domain.AssistantRepository>(
  (ref) {
    return AssistantRepositoryImpl();
  },
  name: 'assistantRepositoryProvider',
);
