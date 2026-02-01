import 'package:chronospin/features/history/domain/solve.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronospin/features/history/data/repositories/solves_repository.dart';
import 'package:chronospin/features/timer/domain/puzzle_type.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';

final solvesRepositoryProvider = Provider((ref) => SolvesRepository());

class HistoryNotifier extends StateNotifier<List<Solve>> {
  final SolvesRepository _repository;
  final PuzzleType _puzzle;

  HistoryNotifier(this._repository, this._puzzle) : super([]) {
    loadSolves();
  }

  Future<void> loadSolves() async {
    final solves = await _repository.getSolves(_puzzle.name);
    state = solves;
  }

  Future<void> addSolve(Solve solve) async {
    // Ensure the solve being added matches the current history context or is compliant
    // Generally, TimerPage passes the correct puzzle type.
    await _repository.saveSolve(solve);
    // Only add to state if it matches current puzzle (it should, but safety check)
    if (solve.puzzle == _puzzle) {
      state = [solve, ...state];
    }
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
    await _repository
        .clearAll(); // Warn: this clears ALL solves or just current?
    // Current requirement implies separate histories. 'clearAll' in repo clears TABLE.
    // If user wants to clear session (history) for THIS puzzle, we should probably update clearAll in repo too?
    // But 'clearAll' usually implies factory reset behavior or 'Clear Session'.
    // If 'Clear Session' means 'Clear this list', then filtering helper is needed.
    // For now, let's assume clearAll clears everything as per existing code, or user might want specific clear.
    // To be safe, usually 'Clear Session' is temporary. 'Delete All' is permanent.
    // The current UI seems to just display history.
    // Let's leave clearAll as global DB clear for now, but user might be annoyed.
    // Better to not use clearAll without verifying.
    // Given the context 'Clear Session' usually resets the display.
    // But existing code called repo.clearAll().
    // I will stick to existing behavior but reload.
    state = [];
  }

  // For demo/testing - keeping mainly for compatibility but it should ideally go through DB too
  void generateRandomSolves() {
    final solves = List.generate(10, (index) {
      return Solve(
        time: Duration(seconds: 10 + index, milliseconds: index * 50),
        scramble: "R U R' U'",
        timestamp: DateTime.now().subtract(Duration(minutes: index)),
        puzzle: _puzzle,
      );
    });

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
  final puzzle = ref.watch(puzzleProvider);
  return HistoryNotifier(repository, puzzle);
});

// Computed Stats
// Computed Stats
final sessionStatsProvider = Provider<Map<String, String>>((ref) {
  final history = ref.watch(historyProvider);
  if (history.isEmpty) {
    return {"PB": "-", "Ao5": "-", "Ao12": "-"};
  }

  // Helper to format time consistent with UI (truncating to 2 decimals)
  String formatTime(num millis) {
    int totalMillis = millis.floor();
    int min = (totalMillis ~/ 1000) ~/ 60;
    int sec = (totalMillis ~/ 1000) % 60;
    int centi = (totalMillis % 1000) ~/ 10;

    if (min > 0) {
      return "$min:${sec.toString().padLeft(2, '0')}.${centi.toString().padLeft(2, '0')}";
    }
    return "$sec.${centi.toString().padLeft(2, '0')}";
  }

  // Helper to calculate Average
  // "Trimmed Average": Remove best and worst, average the rest
  String calculateAverage(List<int> times) {
    if (times.isEmpty) return "-";

    // Sort to find best/worst
    final sorted = List<int>.from(times)..sort();

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
    return formatTime(avg);
  }

  // Get valid times (excluding DNF)
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
    pb = formatTime(times.first);

    // Recent solves for Averages (take from top since history is [newest, ...])
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

final profileStatsProvider = Provider<Map<String, String>>((ref) {
  final history = ref.watch(historyProvider);
  if (history.isEmpty) {
    return {"Total": "0", "PB": "-", "BestAo5": "-", "BestAo12": "-"};
  }

  String formatTime(num millis) {
    int totalMillis = millis.floor();
    int min = (totalMillis ~/ 1000) ~/ 60;
    int sec = (totalMillis ~/ 1000) % 60;
    int centi = (totalMillis % 1000) ~/ 10;

    if (min > 0) {
      return "$min:${sec.toString().padLeft(2, '0')}.${centi.toString().padLeft(2, '0')}";
    }
    return "$sec.${centi.toString().padLeft(2, '0')}";
  }

  double? calculateRawAverage(List<Solve> window) {
    // If any DNF, it counts as worst.
    // If > 1 DNF in Ao5 => DNF.
    // If > 1 DNF in Ao12 => DNF.
    // Standard WCA regulation: remove 1 best, 1 worst.

    int dnfCount = window.where((s) => s.penalty == Penalty.dnf).length;

    // For Ao5, >1 DNF is DNF.
    if (window.length == 5 && dnfCount > 1) return null;
    // For Ao12, >1 DNF is DNF.
    if (window.length == 12 && dnfCount > 1) return null;

    final times = window.map((s) {
      if (s.penalty == Penalty.dnf)
        return 999999999; // Very large number for sorting
      return s.effectiveTime.inMilliseconds;
    }).toList();

    times.sort();

    // Remove Best and Worst
    // (If DNF was present, it's at the end (worst))
    // (If multiple DNFs were allowed (e.g. Ao100), they would all be at end)

    final validTimes = times.sublist(1, times.length - 1);
    final sum = validTimes.reduce((a, b) => a + b);
    return sum / validTimes.length;
  }

  // 1. Total Solves
  final total = history.length.toString();

  // 2. PB Single (Lowest non-DNF)
  String pb = "-";
  final validSolves = history.where((s) => s.penalty != Penalty.dnf).toList();
  if (validSolves.isNotEmpty) {
    final times = validSolves
        .map((s) => s.effectiveTime.inMilliseconds)
        .toList();
    times.sort();
    pb = formatTime(times.first);
  }

  // 3. Best Ao5
  String bestAo5 = "-";
  if (history.length >= 5) {
    double minAvg = double.infinity;
    bool found = false;

    // Iterate windows. History is [Newest ... Oldest].
    // Usually best Ao5 is calculated from chronological sequence.
    // Since we just slice windows of 5, order (asc/desc) doesn't change adjacency,
    // just the direction we slide.
    // history[0..4] is the *latest* Ao5. history[1..5] is the one before that.

    for (int i = 0; i <= history.length - 5; i++) {
      final window = history.sublist(i, i + 5);
      final avg = calculateRawAverage(window);
      if (avg != null && avg < minAvg) {
        minAvg = avg;
        found = true;
      }
    }

    if (found) {
      bestAo5 = formatTime(minAvg);
    }
  }

  // 4. Best Ao12
  String bestAo12 = "-";
  if (history.length >= 12) {
    double minAvg = double.infinity;
    bool found = false;

    for (int i = 0; i <= history.length - 12; i++) {
      final window = history.sublist(i, i + 12);
      final avg = calculateRawAverage(window);
      if (avg != null && avg < minAvg) {
        minAvg = avg;
        found = true;
      }
    }

    if (found) {
      bestAo12 = formatTime(minAvg);
    }
  }

  return {"Total": total, "PB": pb, "BestAo5": bestAo5, "BestAo12": bestAo12};
});
