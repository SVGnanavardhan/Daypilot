import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Future<void>? _initializationFuture;

  static const AndroidNotificationDetails _reminderAndroidDetails =
      AndroidNotificationDetails(
    'daypilot_reminders',
    'DayPilot Reminders',
    channelDescription: 'Task and study reminders',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const NotificationDetails _reminderNotificationDetails =
      NotificationDetails(
    android: _reminderAndroidDetails,
  );

  Future<void> initialize() {
    if (_isInitialized) {
      return Future<void>.value();
    }

    final existingInitialization = _initializationFuture;

    if (existingInitialization != null) {
      return existingInitialization;
    }

    final future = _initializeInternal();
    _initializationFuture = future;

    return future;
  }

  Future<void> _initializeInternal() async {
    try {
      tz.initializeTimeZones();

      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      const initializationSettings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        initializationSettings,
      );

      _isInitialized = true;

      await _requestNotificationPermissionSafely();
    } finally {
      _initializationFuture = null;
    }
  }

  Future<bool?> requestNotificationPermission() async {
    await initialize();

    return _requestNotificationPermissionSafely();
  }

  Future<bool?> _requestNotificationPermissionSafely() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      return null;
    }

    try {
      return await androidPlugin.requestNotificationsPermission();
    } on PlatformException catch (error) {
      if (error.code == 'permissionRequestInProgress') {
        return null;
      }

      rethrow;
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    await initialize();

    await _plugin.show(
      id,
      title,
      body,
      _reminderNotificationDetails,
    );
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime scheduledAt,
  }) async {
    await initialize();

    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      scheduledAt,
      tz.local,
    );

    await _plugin.zonedSchedule(
      id,
      'DayPilot Reminder',
      title,
      scheduledDate,
      _reminderNotificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancel(int id) async {
    await initialize();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
