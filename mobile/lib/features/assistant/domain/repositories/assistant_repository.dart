import '../entities/assistant_message.dart';

/// Domain contract for the DayPilot AI Assistant.
///
/// Presentation and domain layers depend only on this abstraction.
/// Concrete implementations can later use Supabase, an Edge Function,
/// another AI backend, or a local fallback without changing the UI.
abstract class AssistantRepository {
  /// Sends a user message and returns the assistant response.
  Future<AssistantMessage> sendMessage({
    required String message,
  });

  /// Clears the currently stored conversation.
  Future<void> clearConversation();

  /// Returns the current assistant conversation.
  Future<List<AssistantMessage>> getConversation();
}
