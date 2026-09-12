import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Tasks extends Table {
  TextColumn get id => text()();

  /// Supabase Auth user ID that owns this task.
  TextColumn get userId => text()();

  TextColumn get title => text().withLength(
        min: 1,
        max: 255,
      )();

  TextColumn get description => text().nullable()();

  BoolColumn get isCompleted =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get dueDate => dateTime().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncOutbox extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Supabase Auth user ID that owns this sync operation.
  TextColumn get userId => text()();

  TextColumn get action => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    Tasks,
    SyncOutbox,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // V1 local rows did not contain an owner ID.
          // Their ownership cannot be determined safely.
          //
          // Clear only the old local cache/outbox before adding the
          // required non-null userId columns. Cloud data is unaffected
          // and can be downloaded again from Supabase.
          await delete(tasks).go();
          await delete(syncOutbox).go();

          await m.addColumn(
            tasks,
            tasks.userId,
          );

          await m.addColumn(
            syncOutbox,
            syncOutbox.userId,
          );
        }
      },
    );
  }

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'daypilot_db',
    );
  }
}
