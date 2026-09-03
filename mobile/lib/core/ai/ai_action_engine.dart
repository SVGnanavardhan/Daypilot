import 'action_validator.dart';

/// Represents an action requested by the DayPilot AI assistant.
class AIAction {
  const AIAction({
    required this.action,
    required this.entityType,
    required this.entityId,
    this.payload = const <String, dynamic>{},
  });

  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;
}

/// Result returned after processing an AI action.
class AIActionResult {
  const AIActionResult({
    required this.success,
    required this.message,
    this.action,
  });

  final bool success;
  final String message;
  final AIAction? action;
}

/// Safety gateway for AI-generated DayPilot actions.
///
/// This engine validates AI requests before they are allowed to reach
/// repositories or application services.
///
/// Actual task/schedule mutations will be connected later through
/// feature-specific action executors.
class AIActionEngine {
  AIActionEngine({
    ActionValidator validator = const ActionValidator(),
  }) : _validator = validator;

  final ActionValidator _validator;

  Future<AIActionResult> process(AIAction action) async {
    final validation = _validator.validate(
      action: action.action,
      entityType: action.entityType,
      entityId: action.entityId,
    );

    if (!validation.isValid) {
      return AIActionResult(
        success: false,
        message: validation.reason ?? 'Action validation failed.',
        action: action,
      );
    }

    return AIActionResult(
      success: true,
      message: 'Action validated and ready for execution.',
      action: action,
    );
  }
}
