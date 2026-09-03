class CalendarEntry {
  const CalendarEntry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.description,
  });

  final String id;
  final String title;
  final DateTime start;
  final DateTime end;
  final String? description;
}

abstract class CalendarRepository {
  Future<List<CalendarEntry>> getEntriesForDay(DateTime day);
}

class InMemoryCalendarRepository implements CalendarRepository {
  const InMemoryCalendarRepository();

  @override
  Future<List<CalendarEntry>> getEntriesForDay(DateTime day) async {
    return <CalendarEntry>[];
  }
}
