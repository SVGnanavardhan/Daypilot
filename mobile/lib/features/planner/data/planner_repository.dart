import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../schedule/data/free_slot_service.dart';

final plannerRepositoryProvider = Provider<PlannerRepository>(
  (ref) {
    final supabase = ref.watch(supabaseClientProvider);

    return PlannerRepository(
      supabase,
      FreeSlotService(),
    );
  },
  name: 'plannerRepositoryProvider',
);

class PlannerRepository {
  PlannerRepository(
    this._supabase,
    this._freeSlotService,
  );

  final SupabaseClient _supabase;
  final FreeSlotService _freeSlotService;

  Future<List<Map<String, dynamic>>> generatePlan() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return [];
    }

    final taskRows = await _supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .isFilter('deleted_at', null)
        .neq('status', 'Done');

    final scheduleRows =
        await _supabase.from('schedule_entries').select().eq('user_id', userId);

    final profile = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    final tasks = List<Map<String, dynamic>>.from(
      taskRows,
    );

    final schedule = List<Map<String, dynamic>>.from(
      scheduleRows,
    );

    if (tasks.isEmpty) {
      return [];
    }

    final now = DateTime.now();

    final wakeHour = _hourFromTime(
      profile?['wake_time']?.toString(),
      6,
    );

    final sleepHour = _hourFromTime(
      profile?['sleep_time']?.toString(),
      23,
    );

    final todayName = _dayName(now.weekday);

    final todaySchedule = schedule.where(
      (entry) {
        final day = entry['day_of_week']?.toString().trim();

        if (day == null || day.isEmpty) {
          return false;
        }

        return day.toLowerCase() == todayName.toLowerCase();
      },
    ).toList();

    final freeSlots = _freeSlotService.calculate(
      day: now,
      schedule: todaySchedule,
      wakeHour: wakeHour,
      sleepHour: sleepHour,
    );

    for (final task in tasks) {
      final duration = _taskDuration(task);

      task['planner_score'] = _calculateScore(
        task: task,
        freeSlots: freeSlots,
        duration: duration,
        now: now,
      );

      task['recommended_slot'] = _findBestSlot(
        freeSlots,
        duration,
      );
    }

    tasks.sort(
      (first, second) {
        final firstScore = _scoreValue(
          first['planner_score'],
        );

        final secondScore = _scoreValue(
          second['planner_score'],
        );

        final scoreComparison = secondScore.compareTo(firstScore);

        if (scoreComparison != 0) {
          return scoreComparison;
        }

        final firstDue = _parseDateTime(first['due_at']);

        final secondDue = _parseDateTime(second['due_at']);

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

    return tasks;
  }

  double _calculateScore({
    required Map<String, dynamic> task,
    required List<FreeSlot> freeSlots,
    required int duration,
    required DateTime now,
  }) {
    double score = 0;

    score += _priorityScore(
      task['priority']?.toString(),
    );

    final dueDate = _parseDateTime(
      task['due_at'],
    );

    if (dueDate != null) {
      final difference = dueDate.difference(now);

      if (difference.isNegative || difference.inMinutes == 0) {
        score += 50;
      } else if (difference.inHours <= 24) {
        score += 40;
      } else if (difference.inHours <= 72) {
        score += 25;
      } else if (difference.inDays <= 7) {
        score += 15;
      }
    }

    final fittingSlotExists = freeSlots.any(
      (slot) => slot.minutes >= duration,
    );

    if (fittingSlotExists) {
      score += 25;
    } else if (freeSlots.isNotEmpty) {
      score -= 10;
    }

    if (duration <= 30) {
      score += 15;
    } else if (duration <= 60) {
      score += 10;
    } else if (duration <= 90) {
      score += 5;
    }

    final progress = int.tryParse(
      task['progress']?.toString() ?? '',
    );

    if (progress != null && progress > 0 && progress < 100) {
      score += 10;
    }

    return score;
  }

  double _priorityScore(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'high':
        return 40;

      case 'medium':
        return 25;

      case 'low':
        return 10;

      default:
        return 25;
    }
  }

  int _taskDuration(
    Map<String, dynamic> task,
  ) {
    final parsed = int.tryParse(
      task['estimated_duration']?.toString() ?? '',
    );

    if (parsed == null || parsed <= 0) {
      return 30;
    }

    return parsed.clamp(15, 480);
  }

  String? _findBestSlot(
    List<FreeSlot> slots,
    int duration,
  ) {
    for (final slot in slots) {
      if (slot.minutes < duration) {
        continue;
      }

      final end = slot.start.add(
        Duration(minutes: duration),
      );

      return '${_formatTime(slot.start)} - ${_formatTime(end)}';
    }

    return null;
  }

  int _hourFromTime(
    String? value,
    int fallback,
  ) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    final parts = value.split(':');

    if (parts.isEmpty) {
      return fallback;
    }

    final hour = int.tryParse(parts.first);

    if (hour == null || hour < 0 || hour > 23) {
      return fallback;
    }

    return hour;
  }

  DateTime? _parseDateTime(
    value,
  ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  double _scoreValue(
    value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _formatTime(
    DateTime value,
  ) {
    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _dayName(
    int weekday,
  ) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    if (weekday < 1 || weekday > days.length) {
      return 'Monday';
    }

    return days[weekday - 1];
  }
}
