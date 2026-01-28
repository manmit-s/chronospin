import 'package:chronospin/features/history/domain/solve.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HistoryNotifier extends StateNotifier<List<Solve>> {
  HistoryNotifier() : super([]);

  void addSolve(Solve solve) {
    // Add to top of list
    state = [solve, ...state];
  }

  void deleteSolve(String id) {
    state = state.where((s) => s.id != id).toList();
  }

  void updateSolve(Solve updatedSolve) {
    state = [
      for (final solve in state)
        if (solve.id == updatedSolve.id) updatedSolve else solve,
    ];
  }

  void clearSession() {
    state = [];
  }

  // For demo/testing
  void generateRandomSolves() {
    // populate with some dummy data
    state = List.generate(10, (index) {
      return Solve(
        time: Duration(seconds: 10 + index, milliseconds: index * 50),
        scramble: "R U R' U'",
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
      );
    });
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Solve>>((
  ref,
) {
  return HistoryNotifier();
});

// Computed Stats
final sessionStatsProvider = Provider<Map<String, String>>((ref) {
  final history = ref.watch(historyProvider);
  if (history.isEmpty) {
    return {"Mean": "-", "Best": "-", "Worst": "-", "Count": "0"};
  }

  final times = history
      .where((s) => s.penalty != Penalty.dnf)
      .map((s) => s.effectiveTime.inMilliseconds)
      .toList();

  if (times.isEmpty) {
    return {
      "Mean": "DNF",
      "Best": "DNF",
      "Worst": "DNF",
      "Count": history.length.toString(),
    };
  }

  times.sort();
  int best = times.first;
  int worst = times.last;
  double mean = times.reduce((a, b) => a + b) / times.length;

  return {
    "Mean": (mean / 1000).toStringAsFixed(2),
    "Best": (best / 1000).toStringAsFixed(2),
    "Worst": (worst / 1000).toStringAsFixed(2),
    "Count": history.length.toString(),
  };
});
