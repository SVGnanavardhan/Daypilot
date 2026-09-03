/// Represents the result of validating an AI-generated action.
class ActionValidationResult {
  const ActionValidationResult.valid()
      : this._(
          isValid: true,
        );

  const ActionValidationResult.invalid(String reason)
      : this._(
          isValid: false,
          reason: reason,
        );
  const ActionValidationResult._({
    required this.isValid,
    this.reason,
  });

  final bool isValid;
  final String? reason;
}

/// Validates actions before DayPilot allows an AI workflow
/// to execute them.
///
/// This creates a safety boundary between AI-generated decisions
/// and actual application mutations.
class ActionValidator {
  const ActionValidator();

  ActionValidationResult validate({
    required String action,
    required String entityType,
    required String entityId,
  }) {
    final normalizedAction = action.trim().toLowerCase();
    final normalizedEntityType = entityType.trim().toLowerCase();

    if (normalizedAction.isEmpty) {
      return const ActionValidationResult.invalid(
        'Action cannot be empty.',
      );
    }

    if (normalizedEntityType.isEmpty) {
      return const ActionValidationResult.invalid(
        'Entity type cannot be empty.',
      );
    }

    if (entityId.trim().isEmpty) {
      return const ActionValidationResult.invalid(
        'Entity ID cannot be empty.',
      );
    }

    const allowedActions = {
      'create',
      'update',
      'delete',
      'complete',
      'reschedule',
    };

    if (!allowedActions.contains(normalizedAction)) {
      return ActionValidationResult.invalid(
        'Unsupported action: $action',
      );
    }

    const allowedEntityTypes = {
      'task',
      'schedule',
      'reminder',
    };

    if (!allowedEntityTypes.contains(normalizedEntityType)) {
      return ActionValidationResult.invalid(
        'Unsupported entity type: $entityType',
      );
    }

    return const ActionValidationResult.valid();
  }
}
