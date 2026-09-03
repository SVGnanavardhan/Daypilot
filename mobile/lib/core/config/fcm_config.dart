import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Client-side Firebase Cloud Messaging service.
///
/// Responsibilities:
/// - request notification permission
/// - retrieve the device FCM token
/// - observe token refreshes
/// - subscribe/unsubscribe from topics
/// - expose foreground and notification-tap message streams
///
/// Sending push notifications must be handled securely by the backend.
class FCMService {
  FCMService({
    FirebaseMessaging? messaging,
  }) : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission();
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Stream<String> get onTokenRefresh {
    return _messaging.onTokenRefresh;
  }

  Stream<RemoteMessage> get onForegroundMessage {
    return FirebaseMessaging.onMessage;
  }

  Stream<RemoteMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  Future<void> subscribeToTopic(String topic) {
    return _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) {
    return _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> deleteToken() {
    return _messaging.deleteToken();
  }
}

/// Provides the application-wide FCM service.
final fcmServiceProvider = Provider<FCMService>(
  (ref) {
    return FCMService();
  },
  name: 'fcmServiceProvider',
);
