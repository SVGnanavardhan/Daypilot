import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/workload_engine.dart';

class WorkloadState {
  const WorkloadState({
    required this.result,
    this.pendingTasks = 0,
    this.estimatedMinutes = 0,
    this.availableMinutes = 0,
  });

  final WorkloadResult result;
  final int pendingTasks;
  final int estimatedMinutes;
  final int availableMinutes;

  WorkloadState copyWith({
    WorkloadResult? result,
    int? pendingTasks,
    int? estimatedMinutes,
    int? availableMinutes,
  }) {
    return WorkloadState(
      result: result ?? this.result,
      pendingTasks: pendingTasks ?? this.pendingTasks,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      availableMinutes: availableMinutes ?? this.availableMinutes,
    );
  }
}

class WorkloadController extends StateNotifier<WorkloadState> {
  WorkloadController({
    required WorkloadEngine engine,
  })  : _engine = engine,
        super(
          WorkloadState(
            result: engine.calculate(
              pendingTasks: 0,
              estimatedMinutes: 0,
              availableMinutes: 0,
            ),
          ),
        );

  final WorkloadEngine _engine;

  void calculate({
    required int pendingTasks,
    required int estimatedMinutes,
    required int availableMinutes,
  }) {
    final result = _engine.calculate(
      pendingTasks: pendingTasks,
      estimatedMinutes: estimatedMinutes,
      availableMinutes: availableMinutes,
    );

    state = state.copyWith(
      result: result,
      pendingTasks: pendingTasks,
      estimatedMinutes: estimatedMinutes,
      availableMinutes: availableMinutes,
    );
  }

  void reset() {
    calculate(
      pendingTasks: 0,
      estimatedMinutes: 0,
      availableMinutes: 0,
    );
  }
}

final workloadEngineProvider = Provider<WorkloadEngine>(
  (ref) => const WorkloadEngine(),
);

final workloadControllerProvider =
    StateNotifierProvider<WorkloadController, WorkloadState>(
  (ref) => WorkloadController(
    engine: ref.watch(workloadEngineProvider),
  ),
);
