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

    final inspectionSettings = ref.watch(inspectionSettingsProvider);

    // Helper to format inspection time (e.g. -1 becomes +1, -2 becomes +2)
    String formatInspection(int val) {
      if (val <= 0) return "+${val.abs()}";
      return val.toString();
    }

    if (timerState == TimerState.inspection) {
      formattedTime = formatInspection(inspectionTime);
    } else if (timerState == TimerState.ready && inspectionSettings.enabled) {
      formattedTime = formatInspection(inspectionTime);
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

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Allow labels to paint outside if needed
      children: [
        // Inspection Label - Transformed up
        if (timerState == TimerState.inspection)
          Transform.translate(
            offset: const Offset(0, -60),
            child: const Text(
              "INSPECTION",
              style: TextStyle(
                color: Colors.orangeAccent,
                letterSpacing: 2.0,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Main Timer Digits - Centered anchor
        Text(
          formattedTime,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w700,
            fontFamily: 'Outfit',
            color: timerColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        // Hold Label - Transformed down
        if (timerState == TimerState.idle)
          Transform.translate(
            offset: const Offset(0, 60),
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
