import 'package:flutter_riverpod/flutter_riverpod.dart';

// Generates a random scramble
final scrambleProvider = StateProvider<String>((ref) {
  // Simple random scramble logic (or use Cuber's internal tools if available)
  // Since Cuber 0.4.0 might not have a direct 'scramble generator' exposed simply,
  // we can use the Cube object to generate moves.
  // Actually, for now, let's use a standard implementation or mock it if complex.
  // Let's try to generate ~20 random moves.

  List<String> moves = ['R', 'L', 'U', 'D', 'F', 'B'];
  List<String> modifiers = ['', "'", '2'];
  List<String> scramble = [];

  String lastMove = "";

  for (int i = 0; i < 20; i++) {
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

// Holds the current state of the timer (0 = ready, 1 = running, 2 = stopped)
enum TimerState { idle, ready, running, stopped }

class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.idle);

  void setIdle() => state = TimerState.idle;
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
