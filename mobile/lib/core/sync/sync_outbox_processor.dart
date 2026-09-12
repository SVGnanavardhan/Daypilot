import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/app_database.dart';
import '../database/database_provider.dart';

final syncOutboxProvider = Provider<SyncOutboxRepository>(
  (ref) {
    final database = ref.watch(databaseProvider);

    return SyncOutboxRepository(
      database,
      Supabase.instance.client,
    );
  },
  name: 'syncOutboxProvider',
);

class SyncOutboxRepository {
  SyncOutboxRepository(
    this._database,
    this._supabase,
  );

  final AppDatabase _database;
  final SupabaseClient _supabase;

  String? get _userId => _supabase.auth.currentUser?.id;

  String _requireUserId() {
    final userId = _userId;

    if (userId == null || userId.isEmpty) {
      throw StateError(
        'A signed-in user is required to access the sync outbox.',
      );
    }

    return userId;
  }

  Future<int> enqueue({
    required String action,
    required String entityType,
    required String entityId,
    required String payloadJson,
  }) {
    final userId = _requireUserId();

    return _database.into(_database.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            userId: userId,
            action: action,
            entityType: entityType,
            entityId: entityId,
            payloadJson: payloadJson,
          ),
        );
  }

  Future<List<SyncOutboxData>> getPendingOperations() {
    final userId = _userId;

    if (userId == null) {
      return Future.value(
        const <SyncOutboxData>[],
      );
    }

    final query = _database.select(
      _database.syncOutbox,
    )
      ..where(
        (table) => table.userId.equals(userId),
      )
      ..orderBy([
        (table) => OrderingTerm.asc(
              table.createdAt,
            ),
      ]);

    return query.get();
  }

  Stream<int> watchPendingCount() {
    final userId = _userId;

    if (userId == null) {
      return Stream.value(0);
    }

    final query = _database.select(
      _database.syncOutbox,
    )..where(
        (table) => table.userId.equals(userId),
      );

    return query.watch().map(
          (rows) => rows.length,
        );
  }

  Future<int> remove(int id) {
    final userId = _userId;

    if (userId == null) {
      return Future.value(0);
    }

    return (_database.delete(
      _database.syncOutbox,
    )..where(
            (table) =>
                table.id.equals(id) &
                table.userId.equals(userId),
          ))
        .go();
  }

  Future<int> clear() {
    final userId = _userId;

    if (userId == null) {
      return Future.value(0);
    }

    return (_database.delete(
      _database.syncOutbox,
    )..where(
            (table) => table.userId.equals(userId),
          ))
        .go();
  }
}

final pendingSyncCountProvider = StreamProvider<int>(
  (ref) {
    final repository = ref.watch(syncOutboxProvider);

    return repository.watchPendingCount();
  },
  name: 'pendingSyncCountProvider',
);
