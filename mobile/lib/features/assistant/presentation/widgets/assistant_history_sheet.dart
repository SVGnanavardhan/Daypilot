import 'package:flutter/material.dart';

class AssistantHistoryItem {
  const AssistantHistoryItem({
    required this.title,
    required this.timestamp,
    this.preview,
    this.onTap,
  });

  final String title;
  final DateTime timestamp;
  final String? preview;
  final VoidCallback? onTap;
}

class AssistantHistorySheet extends StatelessWidget {
  const AssistantHistorySheet({
    required this.items,
    super.key,
    this.title = 'Conversation history',
    this.onClear,
  });

  final List<AssistantHistoryItem> items;
  final String title;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onClear != null)
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Text(
                  'No previous conversations yet.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: item.preview == null
                          ? Text(_formatTime(item.timestamp))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.preview!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(_formatTime(item.timestamp)),
                              ],
                            ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                      ),
                      onTap: item.onTap,
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime value) {
    final now = DateTime.now();

    final sameDay = now.year == value.year &&
        now.month == value.month &&
        now.day == value.day;

    final hour = value.hour == 0
        ? 12
        : value.hour > 12
            ? value.hour - 12
            : value.hour;

    final minute = value.minute.toString().padLeft(2, '0');
    final period = value.hour >= 12 ? 'PM' : 'AM';

    if (sameDay) {
      return '$hour:$minute $period';
    }

    return '${value.day}/${value.month}/${value.year} • '
        '$hour:$minute $period';
  }
}
