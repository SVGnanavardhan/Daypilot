import 'dart:async';

import '../sync/sync_service.dart';

/// Coordinates lightweight background operations for DayPilot.
///
/// Platform-specific background execution can later be connected through
/// WorkManager or another scheduler without changing feature-layer code.
class BackgroundService {
  BackgroundService({
    required SyncService syncService,
  }) : _syncService = syncService;

  final SyncService _syncService;

  bool _isRunning = false;

  bool get isRunning => _isRunning;

  /// Executes DayPilot background work.
  ///
  /// Currently this triggers the offline-to-cloud synchronization cycle.
  Future<void> run() async {
    if (_isRunning) {
      return;
    }

    _isRunning = true;

    try {
      await _syncService.syncNow();
    } finally {
      _isRunning = false;
    }
  }
}
