import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../data/task_repository.dart';

/// Triggers a remote-to-local task synchronization.
///
/// The UI does not need to wait for this operation before showing data.
/// Existing Drift tasks remain immediately available while synchronization
/// happens in the background.
final taskSyncProvider = FutureProvider<void>(
  (ref) async {
    final repository = ref.watch(taskRepositoryProvider);

    await repository.syncFromSupabase();
  },
  name: 'taskSyncProvider',
);

/// Reactive task stream used across DayPilot.
///
/// Local Drift data is shown immediately while [taskSyncProvider]
/// refreshes the local database from Supabase.
final tasksStreamProvider = StreamProvider<List<Task>>(
  (ref) {
    // Start synchronization without blocking local task rendering.
    ref.watch(taskSyncProvider);

    final repository = ref.watch(taskRepositoryProvider);

    return repository.watchAllTasks();
  },
  name: 'tasksStreamProvider',
);
