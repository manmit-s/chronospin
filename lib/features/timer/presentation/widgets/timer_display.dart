import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerDisplay extends ConsumerWidget {
  const TimerDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerStateProvider);
    final duration = ref.watch(elapsedTimeProvider);

    String formattedTime = _formatTime(duration);
    final inspectionTime = ref.watch(inspectionTimeProvider);

    if (timerState == TimerState.inspection) {
      formattedTime = inspectionTime.toString();
    }

    Color timerColor = Colors.white;
    if (timerState == TimerState.ready) {
      timerColor = Colors.greenAccent;
    }
    if (timerState == TimerState.running) {
      timerColor = Colors.white; // Or hidden if blind
    } else if (timerState == TimerState.inspection) {
      timerColor = Colors.orangeAccent;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit', // Ensure font is loaded or use default
            color: timerColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (timerState == TimerState.idle)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              "HOLD TO START",
              style: TextStyle(
                color: Colors.grey[600],
                letterSpacing: 2.0,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _formatTime(Duration duration) {
    if (duration.inSeconds == 0 && duration.inMilliseconds == 0) return "0.00";

    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    int centiseconds = (duration.inMilliseconds % 1000) ~/ 10;

    String secondsStr = seconds.toString().padLeft(minutes > 0 ? 2 : 1, '0');
    String centiStr = centiseconds.toString().padLeft(2, '0');

    if (minutes > 0) {
      return "$minutes:$secondsStr.$centiStr";
    } else {
      return "$secondsStr.$centiStr";
    }
  }
}
