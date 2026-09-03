import 'package:flutter/material.dart';

class AssistantMessageMetadata extends StatelessWidget {
  const AssistantMessageMetadata({
    super.key,
    this.timestamp,
    this.status,
    this.label,
    this.leading,
    this.trailing,
    this.isUserMessage = false,
  });

  final DateTime? timestamp;
  final String? status;
  final String? label;
  final Widget? leading;
  final Widget? trailing;
  final bool isUserMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final items = <Widget>[];

    if (leading != null) {
      items.add(leading!);
    }

    if (label != null && label!.trim().isNotEmpty) {
      items.add(
        Text(
          label!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (timestamp != null) {
      items.add(
        Text(
          _formatTime(timestamp!),
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (status != null && status!.trim().isNotEmpty) {
      items.add(
        Text(
          status!,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (trailing != null) {
      items.add(trailing!);
    }

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _withSeparators(
          items,
          colorScheme,
        ),
      ),
    );
  }

  List<Widget> _withSeparators(
    List<Widget> items,
    ColorScheme colorScheme,
  ) {
    if (items.length <= 1) {
      return items;
    }

    final result = <Widget>[];

    for (var index = 0; index < items.length; index++) {
      result.add(items[index]);

      if (index < items.length - 1) {
        result.add(
          Text(
            '•',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        );
      }
    }

    return result;
  }

  String _formatTime(DateTime value) {
    final hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';

    final displayHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$displayHour:$minute $period';
  }
}
