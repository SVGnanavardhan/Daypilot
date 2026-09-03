/// Represents the synchronization state of a local entity.
///
/// DayPilot uses these values for offline-first synchronization
/// between the local Drift database and the remote backend.
enum SyncStatus {
  synced,
  pendingCreate,
  pendingUpdate,
  pendingDelete,
  failed,
}

/// Database/API string values used for persistence.
extension SyncStatusValue on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pendingCreate:
        return 'pending_create';
      case SyncStatus.pendingUpdate:
        return 'pending_update';
      case SyncStatus.pendingDelete:
        return 'pending_delete';
      case SyncStatus.failed:
        return 'failed';
    }
  }
}

/// Converts persisted sync-status strings back into [SyncStatus].
extension SyncStatusParser on String {
  SyncStatus toSyncStatus() {
    switch (this) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending_create':
        return SyncStatus.pendingCreate;
      case 'pending_update':
        return SyncStatus.pendingUpdate;
      case 'pending_delete':
        return SyncStatus.pendingDelete;
      case 'failed':
        return SyncStatus.failed;
      default:
        return SyncStatus.failed;
    }
  }
}
