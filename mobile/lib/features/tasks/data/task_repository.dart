// ignore_for_file: avoid_positional_boolean_parameters

import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/notifications/notification_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final db = ref.watch(databaseProvider);

  return TaskRepository(
    db,
    Supabase.instance.client,
  );
});

class TaskRepository {
  TaskRepository(
    this._db,
    this._supabase,
  );

  final AppDatabase _db;
  final SupabaseClient _supabase;

  static const _uuid = Uuid();

  String? get _userId => _supabase.auth.currentUser?.id;

  Stream<List<Task>> watchAllTasks() {
    return (_db.select(_db.tasks)
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .watch();
  }

  Future<void> syncFromSupabase() async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      final rows = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .isFilter('deleted_at', null)
          .order('created_at');

      for (final row in rows) {
        final id = row['id'].toString();

        final dueAt = row['due_at'] != null
            ? DateTime.tryParse(
                row['due_at'].toString(),
              )
            : null;

        final createdAt = DateTime.tryParse(
              row['created_at']?.toString() ?? '',
            ) ??
            DateTime.now();

        final updatedAt = DateTime.tryParse(
              row['updated_at']?.toString() ?? '',
            ) ??
            createdAt;

        final status = row['status']?.toString().toLowerCase();

        final isCompleted = status == 'done' || row['completed_at'] != null;

        await _db.into(_db.tasks).insertOnConflictUpdate(
              TasksCompanion.insert(
                id: id,
                title: row['title']?.toString() ?? 'Untitled Task',
                description: Value(
                  row['description']?.toString(),
                ),
                dueDate: Value(dueAt),
                isCompleted: Value(isCompleted),
                createdAt: Value(createdAt),
                updatedAt: Value(updatedAt),
              ),
            );
      }
    } catch (_) {
      // Offline-first: keep local data if cloud sync fails.
    }
  }

  Future<String> createTask({
    required String title,
    String? description,
    String? subject,
    String priority = 'Medium',
    int estimatedDuration = 30,
    DateTime? dueDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.tasks).insert(
            TasksCompanion.insert(
              id: id,
              title: title,
              description: Value(description),
              dueDate: Value(dueDate),
              createdAt: Value(now),
              updatedAt: Value(now),
            ),
          );

      final payload = jsonEncode({
        'id': id,
        'title': title,
        'description': description,
        'subject': subject,
        'priority': priority,
        'estimated_duration': estimatedDuration,
        'due_at': dueDate?.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await _db.into(_db.syncOutbox).insert(
            SyncOutboxCompanion.insert(
              action: 'CREATE',
              entityType: 'task',
              entityId: id,
              payloadJson: payload,
            ),
          );
    });

    await _pushCreateToSupabase(
      id: id,
      title: title,
      description: description,
      subject: subject,
      priority: priority,
      estimatedDuration: estimatedDuration,
      dueDate: dueDate,
      now: now,
    );

    if (dueDate != null) {
      final reminderTime = dueDate.subtract(
        const Duration(minutes: 30),
      );

      await NotificationService.instance.scheduleTaskReminder(
        id: id.hashCode,
        title: title,
        scheduledAt: reminderTime,
      );
    }

    return id;
  }

  Future<void> updateTask({
    required String id,
    required String title,
    required String priority,
    required int estimatedDuration,
    String? description,
    String? subject,
    DateTime? dueDate,
  }) async {
    final now = DateTime.now();
    final userId = _userId;

    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          title: Value(title),
          description: Value(description),
          dueDate: Value(dueDate),
          updatedAt: Value(now),
        ),
      );

      final payload = jsonEncode({
        'id': id,
        'title': title,
        'description': description,
        'subject': subject,
        'priority': priority,
        'estimated_duration': estimatedDuration,
        'due_at': dueDate?.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });

      await _db.into(_db.syncOutbox).insert(
            SyncOutboxCompanion.insert(
              action: 'UPDATE',
              entityType: 'task',
              entityId: id,
              payloadJson: payload,
            ),
          );
    });

    if (userId != null) {
      try {
        await _supabase
            .from('tasks')
            .update({
              'title': title,
              'description': description,
              'subject': subject,
              'priority': priority,
              'estimated_duration': estimatedDuration,
              'due_at': dueDate?.toIso8601String(),
              'updated_at': now.toIso8601String(),
            })
            .eq('id', id)
            .eq('user_id', userId);
      } catch (_) {}
    }

    await NotificationService.instance.cancel(
      id.hashCode,
    );

    if (dueDate != null) {
      final reminderTime = dueDate.subtract(
        const Duration(minutes: 30),
      );

      await NotificationService.instance.scheduleTaskReminder(
        id: id.hashCode,
        title: title,
        scheduledAt: reminderTime,
      );
    }
  }

  Future<void> toggleTaskCompletion(
    String id,
    bool isCompleted,
  ) async {
    final now = DateTime.now();

    await _db.transaction(() async {
      await (_db.update(_db.tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          isCompleted: Value(isCompleted),
          updatedAt: Value(now),
        ),
      );

      final payload = jsonEncode({
        'id': id,
        'is_completed': isCompleted,
        'updated_at': now.toIso8601String(),
      });

      await _db.into(_db.syncOutbox).insert(
            SyncOutboxCompanion.insert(
              action: 'UPDATE',
              entityType: 'task',
              entityId: id,
              payloadJson: payload,
            ),
          );
    });

    await _pushCompletionToSupabase(
      id,
      isCompleted,
      now,
    );

    if (isCompleted) {
      await NotificationService.instance.cancel(
        id.hashCode,
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final now = DateTime.now();

    await NotificationService.instance.cancel(
      id.hashCode,
    );

    await _db.transaction(() async {
      await (_db.delete(_db.tasks)..where((t) => t.id.equals(id))).go();

      await _db.into(_db.syncOutbox).insert(
            SyncOutboxCompanion.insert(
              action: 'DELETE',
              entityType: 'task',
              entityId: id,
              payloadJson: jsonEncode({
                'id': id,
                'deleted_at': now.toIso8601String(),
              }),
            ),
          );
    });

    await _pushDeleteToSupabase(
      id,
      now,
    );
  }

  Future<void> _pushCreateToSupabase({
    required String id,
    required String title,
    required DateTime now,
    String? description,
    String? subject,
    String priority = 'Medium',
    int estimatedDuration = 30,
    DateTime? dueDate,
  }) async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase.from('tasks').upsert({
        'id': id,
        'user_id': userId,
        'title': title,
        'description': description,
        'subject': subject,
        'priority': priority,
        'estimated_duration': estimatedDuration,
        'due_at': dueDate?.toIso8601String(),
        'status': 'To Do',
        'progress': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
    } catch (_) {
      // Remains queued in SyncOutbox.
    }
  }

  Future<void> _pushCompletionToSupabase(
    String id,
    bool isCompleted,
    DateTime now,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from('tasks')
          .update({
            'status': isCompleted ? 'Done' : 'To Do',
            'progress': isCompleted ? 100 : 0,
            'completed_at': isCompleted ? now.toIso8601String() : null,
            'updated_at': now.toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId);
    } catch (_) {
      // Remains queued locally.
    }
  }

  Future<void> _pushDeleteToSupabase(
    String id,
    DateTime now,
  ) async {
    final userId = _userId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from('tasks')
          .update({
            'deleted_at': now.toIso8601String(),
            'updated_at': now.toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', userId);
    } catch (_) {
      // Remains queued locally.
    }
  }
}
