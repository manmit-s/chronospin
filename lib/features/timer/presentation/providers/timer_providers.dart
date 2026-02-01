import 'package:flutter_riverpod/flutter_riverpod.dart';

// Puzzle Types
enum PuzzleType {
  cube2x2('2x2 Cube'),
  cube3x3('3x3 Cube'),
  cube4x4('4x4 Cube');

  final String label;
  const PuzzleType(this.label);
}

final puzzleProvider = StateProvider<PuzzleType>((ref) => PuzzleType.cube3x3);

// Generates a random scramble
final scrambleProvider = StateProvider<String>((ref) {
  // Simple random scramble logic (or use Cuber's internal tools if available)
  // Since Cuber 0.4.0 might not have a direct 'scramble generator' exposed simply,
  // we can use the Cube object to generate moves.
  // Actually, for now, let's use a standard implementation or mock it if complex.
  // Let's try to generate ~20 random moves.

  final puzzle = ref.watch(puzzleProvider);

  List<String> moves = [];
  int length = 20;

  if (puzzle == PuzzleType.cube2x2) {
    moves = ['R', 'U', 'F'];
    length = 9;
  } else if (puzzle == PuzzleType.cube3x3) {
    moves = ['R', 'L', 'U', 'D', 'F', 'B'];
    length = 20;
  } else if (puzzle == PuzzleType.cube4x4) {
    // Simplified 4x4: Standard moves + Rw etc if we wanted,
    // but sticking to standard notation plus 'w' modifier chance for simplicity.
    moves = ['R', 'L', 'U', 'D', 'F', 'B', 'Uw', 'Fw', 'Rw'];
    length = 40;
  }

  List<String> modifiers = ['', "'", '2'];

  List<String> scramble = [];
  String lastMove = "";

  for (int i = 0; i < length; i++) {
    String move = "";
    do {
      move = (moves..shuffle()).first;
    } while (move == lastMove);

    lastMove = move;
    String mod = (modifiers..shuffle()).first;
    scramble.add("$move$mod");
  }

  return scramble.join(" ");
});

// Holds the current state of the timer
enum TimerState { idle, inspection, ready, running, stopped }

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.idle);

  void setIdle() => state = TimerState.idle;
  void setInspection() => state = TimerState.inspection;
  void setReady() => state = TimerState.ready;
  void setRunning() => state = TimerState.running;
  void setStopped() => state = TimerState.stopped;
}

final timerStateProvider = StateNotifierProvider<TimerNotifier, TimerState>((
  ref,
) {
  return TimerNotifier();
});

final stopWatchProvider = StateProvider<Stopwatch>((ref) => Stopwatch());

final elapsedTimeProvider = StateProvider<Duration>((ref) => Duration.zero);

// Inspection Settings
class InspectionSettings {
  final bool enabled;
  final int duration;

  const InspectionSettings({this.enabled = false, this.duration = 15});

  InspectionSettings copyWith({bool? enabled, int? duration}) {
    return InspectionSettings(
      enabled: enabled ?? this.enabled,
      duration: duration ?? this.duration,
    );
  }
}

class InspectionSettingsNotifier extends StateNotifier<InspectionSettings> {
  InspectionSettingsNotifier() : super(const InspectionSettings());

  void setEnabled(bool enabled) {
    state = state.copyWith(enabled: enabled);
  }

  void setDuration(int duration) {
    state = state.copyWith(duration: duration);
  }
}

final inspectionSettingsProvider =
    StateNotifierProvider<InspectionSettingsNotifier, InspectionSettings>((
      ref,
    ) {
      return InspectionSettingsNotifier();
    });

final inspectionTimeProvider = StateProvider<int>((ref) => 0);
