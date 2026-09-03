import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Represents the high-level connectivity state used by DayPilot.
enum NetworkStatus {
  online,
  offline,
}

/// Service responsible for observing device network connectivity.
class ConnectivityService {
  ConnectivityService({
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Returns the current connectivity state.
  Future<NetworkStatus> getCurrentStatus() async {
    final results = await _connectivity.checkConnectivity();

    return _mapResults(results);
  }

  /// Emits connectivity changes over time.
  Stream<NetworkStatus> watchStatus() {
    return _connectivity.onConnectivityChanged.map(_mapResults).distinct();
  }

  NetworkStatus _mapResults(List<ConnectivityResult> results) {
    if (results.isEmpty ||
        results.every((result) => result == ConnectivityResult.none)) {
      return NetworkStatus.offline;
    }

    return NetworkStatus.online;
  }
}

/// Provides a single connectivity service instance.
final connectivityServiceProvider = Provider<ConnectivityService>(
  (ref) {
    return ConnectivityService();
  },
  name: 'connectivityServiceProvider',
);

/// Reactive provider for the current network state.
final networkStatusProvider = StreamProvider<NetworkStatus>(
  (ref) {
    final service = ref.watch(connectivityServiceProvider);
    return service.watchStatus();
  },
  name: 'networkStatusProvider',
);
