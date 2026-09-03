import '../entities/assistant_message.dart';
import '../repositories/assistant_repository.dart';

class SendAssistantMessage {
  const SendAssistantMessage(
    this._repository,
  );

  final AssistantRepository _repository;

  Future<AssistantMessage> call({
    required String message,
  }) {
    final normalizedMessage = message.trim();

    if (normalizedMessage.isEmpty) {
      throw ArgumentError(
        'Assistant message cannot be empty.',
      );
    }

    return _repository.sendMessage(
      message: normalizedMessage,
    );
  }
}
