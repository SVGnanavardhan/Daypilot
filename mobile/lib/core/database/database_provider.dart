import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

/// Provides a single AppDatabase instance for the lifetime of the app.
///
/// All repositories and services should access Drift through this provider
/// instead of creating their own AppDatabase instances.
final databaseProvider = Provider<AppDatabase>(
  (ref) {
    final database = AppDatabase();

    ref.onDispose(() async {
      await database.close();
    });

    return database;
  },
  name: 'databaseProvider',
);
