import 'package:flutter/material.dart';

class AssistantPermissionSheet extends StatelessWidget {
  const AssistantPermissionSheet({
    required this.title,
    required this.description,
    required this.onAllow,
    super.key,
    this.icon = Icons.lock_outline_rounded,
    this.allowLabel = 'Allow',
    this.denyLabel = 'Not now',
    this.onDeny,
  });

  final String title;
  final String description;
  final IconData icon;
  final String allowLabel;
  final String denyLabel;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onAllow,
                child: Text(allowLabel),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDeny ?? () => Navigator.of(context).pop(false),
                child: Text(denyLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
