class FreeSlot {
  const FreeSlot({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;

  int get minutes => end.difference(start).inMinutes;
}

class FreeSlotService {
  List<FreeSlot> calculate({
    required DateTime day,
    required List<Map<String, dynamic>> schedule,
    int wakeHour = 6,
    int sleepHour = 23,
  }) {
    final safeWakeHour = wakeHour.clamp(0, 23);
    final safeSleepHour = sleepHour.clamp(0, 23);

    final startOfDay = DateTime(
      day.year,
      day.month,
      day.day,
      safeWakeHour,
    );

    final endOfDay = DateTime(
      day.year,
      day.month,
      day.day,
      safeSleepHour,
    );

    if (!endOfDay.isAfter(startOfDay)) {
      return [];
    }

    final busySlots = <({DateTime start, DateTime end})>[];

    for (final entry in schedule) {
      final parsedStart = _parseTime(
        day,
        entry['start_time']?.toString(),
      );

      final parsedEnd = _parseTime(
        day,
        entry['end_time']?.toString(),
      );

      if (parsedStart == null ||
          parsedEnd == null ||
          !parsedEnd.isAfter(parsedStart)) {
        continue;
      }

      final clippedStart =
          parsedStart.isBefore(startOfDay) ? startOfDay : parsedStart;

      final clippedEnd = parsedEnd.isAfter(endOfDay) ? endOfDay : parsedEnd;

      if (!clippedEnd.isAfter(clippedStart)) {
        continue;
      }

      busySlots.add(
        (
          start: clippedStart,
          end: clippedEnd,
        ),
      );
    }

    busySlots.sort(
      (first, second) => first.start.compareTo(second.start),
    );

    final mergedBusySlots = <({DateTime start, DateTime end})>[];

    for (final slot in busySlots) {
      if (mergedBusySlots.isEmpty) {
        mergedBusySlots.add(slot);
        continue;
      }

      final last = mergedBusySlots.last;

      if (!slot.start.isAfter(last.end)) {
        final mergedEnd = slot.end.isAfter(last.end) ? slot.end : last.end;

        mergedBusySlots[mergedBusySlots.length - 1] = (
          start: last.start,
          end: mergedEnd,
        );

        continue;
      }

      mergedBusySlots.add(slot);
    }

    final freeSlots = <FreeSlot>[];

    var cursor = startOfDay;

    for (final busy in mergedBusySlots) {
      if (busy.start.isAfter(cursor)) {
        freeSlots.add(
          FreeSlot(
            start: cursor,
            end: busy.start,
          ),
        );
      }

      if (busy.end.isAfter(cursor)) {
        cursor = busy.end;
      }
    }

    if (cursor.isBefore(endOfDay)) {
      freeSlots.add(
        FreeSlot(
          start: cursor,
          end: endOfDay,
        ),
      );
    }

    return freeSlots
        .where(
          (slot) => slot.minutes >= 15,
        )
        .toList();
  }

  DateTime? _parseTime(
    DateTime day,
    String? value,
  ) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return DateTime(
      day.year,
      day.month,
      day.day,
      hour,
      minute,
    );
  }
}
