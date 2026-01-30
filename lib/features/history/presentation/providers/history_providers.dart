import 'package:chronospin/features/history/domain/solve.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:chronospin/features/history/data/repositories/solves_repository.dart';

final solvesRepositoryProvider = Provider((ref) => SolvesRepository());

class HistoryNotifier extends StateNotifier<List<Solve>> {
  final SolvesRepository _repository;

  HistoryNotifier(this._repository) : super([]) {
    loadSolves();
  }

  Future<void> loadSolves() async {
    final solves = await _repository.getSolves();
    state = solves;
  }

  Future<void> addSolve(Solve solve) async {
    await _repository.saveSolve(solve);
    state = [solve, ...state];
  }

  Future<void> deleteSolve(String id) async {
    await _repository.deleteSolve(id);
    state = state.where((s) => s.id != id).toList();
  }

  // Not strictly DB, but keeping for reference if needed
  void updateSolve(Solve updatedSolve) {
    // Ideally this should also save to DB
    _repository.saveSolve(updatedSolve);
    state = [
      for (final solve in state)
        if (solve.id == updatedSolve.id) updatedSolve else solve,
    ];
  }

  Future<void> clearSession() async {
    await _repository.clearAll();
    state = [];
  }

  // For demo/testing - keeping mainly for compatibility but it should ideally go through DB too
  void generateRandomSolves() {
    final solves = List.generate(10, (index) {
      return Solve(
        time: Duration(seconds: 10 + index, milliseconds: index * 50),
        scramble: "R U R' U'",
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
      );
    });

    // We can choose to save these or just show them. For consistency let's just show them in state.
    state = solves;
    for (var s in solves) {
      _repository.saveSolve(s);
    }
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, List<Solve>>((
  ref,
) {
  final repository = ref.watch(solvesRepositoryProvider);
  return HistoryNotifier(repository);
});

// Computed Stats
// Computed Stats
final sessionStatsProvider = Provider<Map<String, String>>((ref) {
  final history = ref.watch(historyProvider);
  if (history.isEmpty) {
    return {"PB": "-", "Ao5": "-", "Ao12": "-"};
  }

  // Helper to calculate Average
  // "Trimmed Average": Remove best and worst, average the rest
  String calculateAverage(List<int> times) {
    if (times.isEmpty) return "-";
    // For proper Ao5/Ao12, we need exact count (5 or 12)
    // But usually in timers, if you have 5 solves, you show Ao5.

    // Sort to find best/worst
    final sorted = List<int>.from(times)..sort();

    // Standard rule: remove top 5% and bottom 5% (rounded up)
    // For Ao5: remove 1 best, 1 worst (count 5)
    // For Ao12: remove 1 best, 1 worst (count 12)
    // Using simplified logic here: remove min and max if length >= 3

    int sum = 0;
    int count = 0;

    if (times.length >= 3) {
      // Remove best and worst
      final validTimes = sorted.sublist(1, sorted.length - 1);
      sum = validTimes.reduce((a, b) => a + b);
      count = validTimes.length;
    } else {
      sum = sorted.reduce((a, b) => a + b);
      count = sorted.length;
    }

    double avg = sum / count;
    return (avg / 1000).toStringAsFixed(2);
  }

  // Get valid times (excluding DNF)
  // TODO: Handle DNF properly in averages (usually counts as worst)
  final validSolves = history.where((s) => s.penalty != Penalty.dnf).toList();

  String pb = "-";
  String ao5 = "-";
  String ao12 = "-";

  if (validSolves.isNotEmpty) {
    // PB (Best Single)
    final times = validSolves
        .map((s) => s.effectiveTime.inMilliseconds)
        .toList();
    times.sort();
    pb = (times.first / 1000).toStringAsFixed(2);

    // Recent solves for Averages (take from top since history is [newest, ...])
    // history has newest first.
    // For Ao5, we need the last 5 solves added.
    // Wait, history is usually reverse chronological? Yes, in addSolve we do [solve, ...state]

    if (history.length >= 5) {
      final last5 = history
          .take(5)
          .map((s) => s.effectiveTime.inMilliseconds)
          .toList();
      ao5 = calculateAverage(last5);
    }

    if (history.length >= 12) {
      final last12 = history
          .take(12)
          .map((s) => s.effectiveTime.inMilliseconds)
          .toList();
      ao12 = calculateAverage(last12);
    }
  }

  return {
    "PB": pb,
    "Ao5": ao5,
    "Ao12": ao12,
    "Count": validSolves.length.toString(),
  };
});
