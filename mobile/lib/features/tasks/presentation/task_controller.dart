import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../data/task_repository.dart';

/// Synchronizes the currently authenticated user's tasks
/// from Supabase into the local Drift database.
///
/// This provider depends on the authenticated user ID.
/// Therefore, when User A logs out and User B logs in,
/// Riverpod automatically creates a new synchronization
/// operation for User B.
final taskSyncProvider = FutureProvider<void>(
  (ref) async {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id;

    // No authenticated user means there is nothing to sync.
    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.isEmpty) {
      return;
    }

    final repository = ref.watch(taskRepositoryProvider);

    await repository.syncFromSupabase();
  },
  name: 'taskSyncProvider',
);

/// Reactive task stream for the currently authenticated user.
///
/// IMPORTANT:
/// This provider explicitly watches the authenticated user ID.
///
/// This guarantees:
///
/// User A login
///   -> stream subscribes to User A's local tasks.
///
/// User A logout
///   -> provider rebuilds and returns an empty stream.
///
/// User B login
///   -> provider rebuilds and subscribes only to User B's tasks.
///
/// Therefore, tasks from a previous account cannot remain visible
/// while waiting for manual synchronization.
final tasksStreamProvider = StreamProvider<List<Task>>(
  (ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.user?.id;

    if (authState.status != AuthStatus.authenticated ||
        userId == null ||
        userId.isEmpty) {
      return Stream.value(
        const <Task>[],
      );
    }

    // Start background cloud -> local synchronization for
    // the CURRENT authenticated user.
    ref.watch(taskSyncProvider);

    final repository = ref.watch(taskRepositoryProvider);

    // TaskRepository.watchAllTasks() also filters the Drift query
    // using Supabase's current user ID, providing a second layer
    // of per-user isolation.
    return repository.watchAllTasks();
  },
  name: 'tasksStreamProvider',
);
