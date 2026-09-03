import 'package:flutter/material.dart';

import 'assistant_context_card.dart';

class AssistantContextSummary extends StatelessWidget {
  const AssistantContextSummary({
    super.key,
    this.pendingTasks = 0,
    this.todayEvents = 0,
    this.nextTask,
    this.nextFreeSlot,
    this.onTasksTap,
    this.onScheduleTap,
  });

  final int pendingTasks;
  final int todayEvents;
  final String? nextTask;
  final String? nextFreeSlot;

  final VoidCallback? onTasksTap;
  final VoidCallback? onScheduleTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your DayPilot Context',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          AssistantContextCard(
            title: 'Pending Tasks',
            value: '$pendingTasks',
            icon: Icons.task_alt_outlined,
            subtitle: nextTask == null ? 'No upcoming task' : 'Next: $nextTask',
            onTap: onTasksTap,
          ),
          AssistantContextCard(
            title: "Today's Schedule",
            value: '$todayEvents events',
            icon: Icons.calendar_today_outlined,
            subtitle: nextFreeSlot == null
                ? 'Free slot unavailable'
                : 'Next free: $nextFreeSlot',
            onTap: onScheduleTap,
          ),
        ],
      ),
    );
  }
}
