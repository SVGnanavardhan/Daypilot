import 'package:flutter/material.dart';

class AssistantActionPreview extends StatelessWidget {
  const AssistantActionPreview({
    required this.action,
    required this.entityType,
    required this.title,
    super.key,
    this.description,
    this.onConfirm,
    this.onCancel,
    this.isProcessing = false,
  });

  final String action;
  final String entityType;
  final String title;
  final String? description;

  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForAction(action),
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatAction(action),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatEntityType(entityType),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (description != null && description!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (onConfirm != null || onCancel != null) ...[
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onCancel != null)
                    TextButton(
                      onPressed: isProcessing ? null : onCancel,
                      child: const Text('Cancel'),
                    ),
                  if (onCancel != null && onConfirm != null)
                    const SizedBox(width: 8),
                  if (onConfirm != null)
                    FilledButton.icon(
                      onPressed: isProcessing ? null : onConfirm,
                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                            ),
                      label: Text(
                        isProcessing ? 'Applying...' : 'Confirm',
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForAction(String value) {
    switch (value.trim().toLowerCase()) {
      case 'create':
        return Icons.add_task_rounded;

      case 'update':
        return Icons.edit_outlined;

      case 'delete':
        return Icons.delete_outline_rounded;

      case 'complete':
        return Icons.task_alt_rounded;

      case 'reschedule':
        return Icons.schedule_send_rounded;

      default:
        return Icons.auto_awesome_rounded;
    }
  }

  String _formatAction(String value) {
    switch (value.trim().toLowerCase()) {
      case 'create':
        return 'Create';

      case 'update':
        return 'Update';

      case 'delete':
        return 'Delete';

      case 'complete':
        return 'Complete';

      case 'reschedule':
        return 'Reschedule';

      default:
        return 'Suggested Action';
    }
  }

  String _formatEntityType(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return 'DayPilot action';
    }

    return '${normalized[0].toUpperCase()}${normalized.substring(1)}';
  }
}
