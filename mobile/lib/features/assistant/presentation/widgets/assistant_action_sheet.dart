import 'package:flutter/material.dart';

class AssistantActionSheetItem {
  const AssistantActionSheetItem({
    required this.label,
    required this.icon,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });

  final String label;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool enabled;
}

class AssistantActionSheet extends StatelessWidget {
  const AssistantActionSheet({
    required this.actions,
    super.key,
    this.title = 'Actions',
  });

  final List<AssistantActionSheetItem> actions;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          16,
          4,
          16,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...actions.map(
              (action) => _AssistantActionTile(
                action: action,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantActionTile extends StatelessWidget {
  const _AssistantActionTile({
    required this.action,
  });

  final AssistantActionSheetItem action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final foregroundColor = !action.enabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : action.isDestructive
            ? colorScheme.error
            : colorScheme.onSurface;

    return ListTile(
      enabled: action.enabled,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        action.icon,
        color: foregroundColor,
      ),
      title: Text(
        action.label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: action.subtitle == null
          ? null
          : Text(
              action.subtitle!,
            ),
      onTap: action.enabled ? action.onTap : null,
    );
  }
}
