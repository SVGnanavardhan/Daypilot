import 'package:flutter/material.dart';

/// A reusable quick-actions section for the DayPilot AI Assistant.
///
/// This widget is intentionally UI-only. The parent screen decides what
/// happens when an action is selected, which keeps it reusable and avoids
/// coupling it to a specific state-management implementation.
class AssistantQuickActions extends StatelessWidget {
  const AssistantQuickActions({
    required this.onActionSelected,
    super.key,
  });

  final ValueChanged<AssistantQuickAction> onActionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AssistantQuickAction.values
              .map(
                (action) => _QuickActionChip(
                  action: action,
                  onTap: () => onActionSelected(action),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.action,
    required this.onTap,
  });

  final AssistantQuickAction action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ActionChip(
      avatar: Icon(
        action.icon,
        size: 18,
        color: colorScheme.primary,
      ),
      label: Text(action.label),
      tooltip: action.description,
      onPressed: onTap,
    );
  }
}

enum AssistantQuickAction {
  planMyDay,
  prioritizeTasks,
  suggestFocusTime,
  reviewSchedule,
  productivityTip,
}

extension AssistantQuickActionX on AssistantQuickAction {
  String get label {
    switch (this) {
      case AssistantQuickAction.planMyDay:
        return 'Plan my day';
      case AssistantQuickAction.prioritizeTasks:
        return 'Prioritize tasks';
      case AssistantQuickAction.suggestFocusTime:
        return 'Find focus time';
      case AssistantQuickAction.reviewSchedule:
        return 'Review schedule';
      case AssistantQuickAction.productivityTip:
        return 'Productivity tip';
    }
  }

  String get description {
    switch (this) {
      case AssistantQuickAction.planMyDay:
        return 'Create a practical plan for today.';
      case AssistantQuickAction.prioritizeTasks:
        return 'Identify which tasks should be handled first.';
      case AssistantQuickAction.suggestFocusTime:
        return 'Find a suitable time for focused work.';
      case AssistantQuickAction.reviewSchedule:
        return 'Review upcoming schedule and commitments.';
      case AssistantQuickAction.productivityTip:
        return 'Get a useful productivity suggestion.';
    }
  }

  IconData get icon {
    switch (this) {
      case AssistantQuickAction.planMyDay:
        return Icons.auto_awesome_rounded;
      case AssistantQuickAction.prioritizeTasks:
        return Icons.low_priority_rounded;
      case AssistantQuickAction.suggestFocusTime:
        return Icons.center_focus_strong_rounded;
      case AssistantQuickAction.reviewSchedule:
        return Icons.calendar_month_rounded;
      case AssistantQuickAction.productivityTip:
        return Icons.lightbulb_outline_rounded;
    }
  }
}
