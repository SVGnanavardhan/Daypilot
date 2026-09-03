import '../notifications/notification_service.dart';

/// Central reminder engine for DayPilot.
///
/// Feature layers should use this engine instead of directly interacting
/// with the notification plugin.
class ReminderEngine {
  ReminderEngine({
    NotificationService? notificationService,
  }) : _notificationService =
            notificationService ?? NotificationService.instance;

  final NotificationService _notificationService;

  /// Creates a stable notification ID from an entity ID.
  int notificationIdFor(String entityId) {
    return entityId.hashCode & 0x7fffffff;
  }

  /// Schedules a task reminder.
  Future<void> scheduleTaskReminder({
    required String taskId,
    required String title,
    required DateTime scheduledAt,
  }) async {
    if (!scheduledAt.isAfter(DateTime.now())) {
      return;
    }

    await _notificationService.scheduleTaskReminder(
      id: notificationIdFor(taskId),
      title: title,
      scheduledAt: scheduledAt,
    );
  }

  /// Displays a reminder immediately.
  Future<void> showReminderNow({
    required String entityId,
    required String title,
    required String body,
  }) async {
    await _notificationService.showNow(
      id: notificationIdFor(entityId),
      title: title,
      body: body,
    );
  }

  /// Cancels the reminder associated with a task.
  Future<void> cancelTaskReminder(String taskId) async {
    await _notificationService.cancel(
      notificationIdFor(taskId),
    );
  }

  /// Cancels every scheduled DayPilot notification.
  Future<void> cancelAll() async {
    await _notificationService.cancelAll();
  }
}
