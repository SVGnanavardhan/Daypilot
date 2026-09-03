import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/planner_repository.dart';

/// Generates the current DayPilot AI task plan.
final plannerProvider = FutureProvider<List<Map<String, dynamic>>>(
  (ref) async {
    final repository = ref.watch(plannerRepositoryProvider);

    return repository.generatePlan();
  },
  name: 'plannerProvider',
);
