import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_repository.dart';

class NotificationState {
  const NotificationState({
    this.items = const <AppNotificationItem>[],
    this.isLoading = false,
    this.error,
  });

  final List<AppNotificationItem> items;
  final bool isLoading;
  final String? error;

  int get unreadCount => items.where((item) => !item.isRead).length;

  NotificationState copyWith({
    List<AppNotificationItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NotificationController extends StateNotifier<NotificationState> {
  NotificationController({
    required NotificationRepository repository,
  })  : _repository = repository,
        super(const NotificationState()) {
    unawaited(loadNotifications());
  }

  final NotificationRepository _repository;

  Future<void> loadNotifications() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );

    try {
      final items = await _repository.getNotifications();

      state = state.copyWith(
        items: items,
        isLoading: false,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
  }

  Future<void> delete(String id) async {
    await _repository.deleteNotification(id);
    await loadNotifications();
  }

  Future<void> refresh() => loadNotifications();
}

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => InMemoryNotificationRepository(),
);

final notificationControllerProvider =
    StateNotifierProvider<NotificationController, NotificationState>(
  (ref) => NotificationController(
    repository: ref.watch(notificationRepositoryProvider),
  ),
);
