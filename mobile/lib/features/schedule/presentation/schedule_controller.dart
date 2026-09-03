import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/schedule_repository.dart';

/// Loads the authenticated user's schedule from the repository.
final scheduleProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final repository = ref.watch(scheduleRepositoryProvider);

    return repository.getSchedule();
  },
  name: 'scheduleProvider',
);
