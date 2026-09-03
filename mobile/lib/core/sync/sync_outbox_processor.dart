import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

final syncOutboxProvider = Provider<SyncOutboxRepository>(
  (ref) {
    final database = ref.watch(databaseProvider);

    return SyncOutboxRepository(
      database,
    );
  },
  name: 'syncOutboxProvider',
);

class SyncOutboxRepository {
  SyncOutboxRepository(
    this._database,
  );

  final AppDatabase _database;

  Future<int> enqueue({
    required String action,
    required String entityType,
    required String entityId,
    required String payloadJson,
  }) {
    return _database.into(_database.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            action: action,
            entityType: entityType,
            entityId: entityId,
            payloadJson: payloadJson,
          ),
        );
  }

  Future<List<SyncOutboxData>> getPendingOperations() {
    final query = _database.select(
      _database.syncOutbox,
    )..orderBy([
        (table) => OrderingTerm.asc(
              table.createdAt,
            ),
      ]);

    return query.get();
  }

  Stream<int> watchPendingCount() {
    return _database.select(_database.syncOutbox).watch().map(
          (rows) => rows.length,
        );
  }

  Future<int> remove(int id) {
    return (_database.delete(
      _database.syncOutbox,
    )..where(
            (table) => table.id.equals(id),
          ))
        .go();
  }

  Future<int> clear() {
    return _database.delete(_database.syncOutbox).go();
  }
}

final pendingSyncCountProvider = StreamProvider<int>(
  (ref) {
    final repository = ref.watch(syncOutboxProvider);

    return repository.watchPendingCount();
  },
  name: 'pendingSyncCountProvider',
);
