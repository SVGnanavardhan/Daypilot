import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../connectivity/connectivity_service.dart';

/// Handles synchronization between DayPilot's local data
/// and the remote Supabase backend.
///
/// Full outbox processing will be connected when the local
/// repositories are integrated with the sync engine.
class SyncService {
  SyncService({
    required SupabaseClient supabase,
    required ConnectivityService connectivityService,
  })  : _supabase = supabase,
        _connectivityService = connectivityService;

  final SupabaseClient _supabase;
  final ConnectivityService _connectivityService;

  bool _isSyncing = false;

  bool get isSyncing => _isSyncing;

  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Attempts to start a synchronization cycle.
  ///
  /// Sync is skipped when:
  /// - another sync is already running,
  /// - the user is not authenticated,
  /// - the device is offline.
  Future<void> syncNow() async {
    if (_isSyncing || !isAuthenticated) {
      return;
    }

    final networkStatus = await _connectivityService.getCurrentStatus();

    if (networkStatus == NetworkStatus.offline) {
      return;
    }

    _isSyncing = true;

    try {
      await _supabase.auth.refreshSession();

      // Outbox processing will be connected when repository-level
      // offline synchronization is enabled.
    } finally {
      _isSyncing = false;
    }
  }
}

/// Provides the application-wide synchronization service.
final syncServiceProvider = Provider<SyncService>(
  (ref) {
    return SyncService(
      supabase: Supabase.instance.client,
      connectivityService: ref.watch(connectivityServiceProvider),
    );
  },
  name: 'syncServiceProvider',
);
