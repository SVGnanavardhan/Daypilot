import 'package:supabase_flutter/supabase_flutter.dart';

class RescheduleService {
  RescheduleService(this._supabase);

  final SupabaseClient _supabase;

  Future<int> rescheduleMissedTasks() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 0;
    }

    final now = DateTime.now();

    final rows = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .neq('status', 'Done')
        .isFilter('deleted_at', null);

    final missedTasks = rows.where(
      (task) {
        final dueValue = task['due_at'];

        if (dueValue == null) {
          return false;
        }

        final dueDate = DateTime.tryParse(
          dueValue.toString(),
        );

        if (dueDate == null) {
          return false;
        }

        return dueDate.isBefore(now);
      },
    ).toList()
      ..sort(
        (first, second) {
          final firstDue = DateTime.tryParse(
            first['due_at']?.toString() ?? '',
          );

          final secondDue = DateTime.tryParse(
            second['due_at']?.toString() ?? '',
          );

          if (firstDue == null && secondDue == null) {
            return 0;
          }

          if (firstDue == null) {
            return 1;
          }

          if (secondDue == null) {
            return -1;
          }

          return firstDue.compareTo(secondDue);
        },
      );

    var cursor = _nextAvailableSlot(now);
    var rescheduled = 0;

    for (final task in missedTasks) {
      final taskId = task['id']?.toString();

      if (taskId == null || taskId.isEmpty) {
        continue;
      }

      final duration = int.tryParse(
            task['estimated_duration']?.toString() ?? '',
          ) ??
          30;

      final safeDuration = duration.clamp(15, 180);

      final slotStart = _normalizeSlot(cursor);

      await _supabase
          .from('tasks')
          .update({
            'due_at': slotStart.toIso8601String(),
            'status': 'To Do',
            'updated_at': now.toIso8601String(),
          })
          .eq('id', taskId)
          .eq('user_id', userId);

      rescheduled++;

      cursor = slotStart.add(
        Duration(
          minutes: safeDuration + 15,
        ),
      );
    }

    return rescheduled;
  }

  DateTime _nextAvailableSlot(DateTime now) {
    final candidate = now.add(
      const Duration(hours: 1),
    );

    return _normalizeSlot(candidate);
  }

  DateTime _normalizeSlot(DateTime slot) {
    if (slot.hour < 7) {
      return DateTime(
        slot.year,
        slot.month,
        slot.day,
        7,
      );
    }

    if (slot.hour >= 22) {
      return DateTime(
        slot.year,
        slot.month,
        slot.day + 1,
        7,
      );
    }

    return slot;
  }
}
