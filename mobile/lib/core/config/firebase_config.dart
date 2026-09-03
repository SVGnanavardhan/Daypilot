import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Initializes Firebase for DayPilot.
///
/// Firebase is currently used primarily for services such as
/// Firebase Cloud Messaging (FCM).
final firebaseAppProvider = FutureProvider<FirebaseApp>(
  (ref) async {
    if (Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }

    return Firebase.initializeApp();
  },
  name: 'firebaseAppProvider',
);
