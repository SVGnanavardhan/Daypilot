import 'package:supabase_flutter/supabase_flutter.dart';

import '../connectivity/connectivity_service.dart';

/// Represents the health state of a DayPilot core dependency.
enum HealthStatus {
  healthy,
  unavailable,
}

/// Snapshot of DayPilot's core runtime health.
class AppHealthStatus {
  const AppHealthStatus({
    required this.network,
    required this.supabase,
  });

  final HealthStatus network;
  final HealthStatus supabase;

  bool get isHealthy =>
      network == HealthStatus.healthy && supabase == HealthStatus.healthy;
}

/// Performs lightweight runtime checks for critical DayPilot services.
class AppHealthCheck {
  AppHealthCheck({
    required ConnectivityService connectivityService,
    required SupabaseClient supabase,
  })  : _connectivityService = connectivityService,
        _supabase = supabase;

  final ConnectivityService _connectivityService;
  final SupabaseClient _supabase;

  Future<AppHealthStatus> check() async {
    final networkStatus = await _connectivityService.getCurrentStatus();

    final network = networkStatus == NetworkStatus.online
        ? HealthStatus.healthy
        : HealthStatus.unavailable;

    HealthStatus supabase;

    try {
      _supabase.auth.currentSession;
      supabase = HealthStatus.healthy;
    } catch (_) {
      supabase = HealthStatus.unavailable;
    }

    return AppHealthStatus(
      network: network,
      supabase: supabase,
    );
  }
}
