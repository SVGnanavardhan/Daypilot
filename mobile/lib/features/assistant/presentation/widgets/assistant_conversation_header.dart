import 'package:flutter/material.dart';

class AssistantConversationHeader extends StatelessWidget {
  const AssistantConversationHeader({
    super.key,
    this.title = 'DayPilot Assistant',
    this.subtitle = 'Plan smarter and stay focused',
    this.icon = Icons.auto_awesome_rounded,
    this.isOnline = true,
    this.onClearConversation,
    this.onMorePressed,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool isOnline;
  final VoidCallback? onClearConversation;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
          ),
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 21,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isOnline ? colorScheme.primary : colorScheme.outline,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasSubtitle) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onClearConversation != null)
            IconButton(
              onPressed: onClearConversation,
              tooltip: 'Clear conversation',
              icon: const Icon(
                Icons.delete_sweep_outlined,
              ),
            ),
          if (onMorePressed != null)
            IconButton(
              onPressed: onMorePressed,
              tooltip: 'More options',
              icon: const Icon(
                Icons.more_vert_rounded,
              ),
            ),
        ],
      ),
    );
  }
}
