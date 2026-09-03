import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/analytics_repository.dart';

/// Loads the current DayPilot productivity summary.
final analyticsSummaryProvider = FutureProvider<Map<String, dynamic>>(
  (ref) async {
    final repository = ref.watch(analyticsRepositoryProvider);

    return repository.getProductivitySummary();
  },
  name: 'analyticsSummaryProvider',
);
