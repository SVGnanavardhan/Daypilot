import '../sync/sync_service.dart';

/// Coordinates lightweight background operations for DayPilot.
///
/// Platform-specific background scheduling can later be connected
/// without changing the rest of the application.
class BackgroundService {
  BackgroundService({
    required SyncService syncService,
  }) : _syncService = syncService;

  final SyncService _syncService;

  bool _isRunning = false;

  bool get isRunning => _isRunning;

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
