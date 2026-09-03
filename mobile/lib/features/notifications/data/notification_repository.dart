class AppNotificationItem {
  const AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  AppNotificationItem copyWith({
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

abstract class NotificationRepository {
  Future<List<AppNotificationItem>> getNotifications();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(String id);
}

class InMemoryNotificationRepository implements NotificationRepository {
  final List<AppNotificationItem> _items = <AppNotificationItem>[];

  @override
  Future<List<AppNotificationItem>> getNotifications() async {
    final result = List<AppNotificationItem>.of(_items)
      ..sort(
        (a, b) => b.createdAt.compareTo(a.createdAt),
      );

    return List<AppNotificationItem>.unmodifiable(result);
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    _items.removeWhere((item) => item.id == id);
  }
}
