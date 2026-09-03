import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>(
  (ref) {
    final supabase = ref.watch(supabaseClientProvider);

    return ScheduleRepository(supabase);
  },
  name: 'scheduleRepositoryProvider',
);

class ScheduleRepository {
  ScheduleRepository(this._supabase);

  final SupabaseClient _supabase;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<List<Map<String, dynamic>>> getSchedule() async {
    final userId = _userId;

    if (userId == null) {
      return [];
    }

    final rows = await _supabase
        .from('schedule_entries')
        .select()
        .eq('user_id', userId)
        .order('day_of_week')
        .order('start_time');

    return List<Map<String, dynamic>>.from(rows);
  }

  Future<void> addScheduleEntry({
    required String title,
    required String dayOfWeek,
    required String startTime,
    required String endTime,
    String? location,
  }) async {
    final userId = _requireUserId();

    final normalizedTitle = title.trim();
    final normalizedDay = dayOfWeek.trim();
    final normalizedStartTime = startTime.trim();
    final normalizedEndTime = endTime.trim();

    if (normalizedTitle.isEmpty) {
      throw ArgumentError.value(
        title,
        'title',
        'Schedule title cannot be empty.',
      );
    }

    if (normalizedDay.isEmpty) {
      throw ArgumentError.value(
        dayOfWeek,
        'dayOfWeek',
        'Day of week cannot be empty.',
      );
    }

    if (normalizedStartTime.isEmpty || normalizedEndTime.isEmpty) {
      throw ArgumentError(
        'Start time and end time are required.',
      );
    }

    await _supabase.from('schedule_entries').insert({
      'user_id': userId,
      'title': normalizedTitle,
      'day_of_week': normalizedDay,
      'start_time': normalizedStartTime,
      'end_time': normalizedEndTime,
      'location': _normalizeNullableText(location),
    });
  }

  Future<void> deleteScheduleEntry(String id) async {
    final userId = _requireUserId();
    final normalizedId = id.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        id,
        'id',
        'Schedule entry ID cannot be empty.',
      );
    }

    await _supabase
        .from('schedule_entries')
        .delete()
        .eq('id', normalizedId)
        .eq('user_id', userId);
  }

  String _requireUserId() {
    final userId = _userId;

    if (userId == null) {
      throw StateError(
        'User must be authenticated to modify the schedule.',
      );
    }

    return userId;
  }

  String? _normalizeNullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}
