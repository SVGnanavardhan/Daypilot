import 'package:flutter/material.dart';

class AssistantTimestamp extends StatelessWidget {
  const AssistantTimestamp({
    required this.dateTime,
    super.key,
    this.prefix,
    this.showDate = false,
    this.textAlign = TextAlign.start,
  });

  final DateTime dateTime;
  final String? prefix;
  final bool showDate;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formatted =
        showDate ? _formatDateTime(dateTime) : _formatTime(dateTime);

    final text = prefix == null || prefix!.trim().isEmpty
        ? formatted
        : '${prefix!.trim()} $formatted';

    return Text(
      text,
      textAlign: textAlign,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  String _formatTime(DateTime value) {
    final hour = value.hour;
    final minute = value.minute.toString().padLeft(2, '0');

    final period = hour >= 12 ? 'PM' : 'AM';

    final normalizedHour = hour == 0
        ? 12
        : hour > 12
            ? hour - 12
            : hour;

    return '$normalizedHour:$minute $period';
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year;

    return '$day/$month/$year • ${_formatTime(value)}';
  }
}
