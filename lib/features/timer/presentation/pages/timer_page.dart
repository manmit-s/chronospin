import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/core/presentation/widgets/app_drawer.dart';
import 'package:chronospin/features/history/presentation/pages/history_page.dart';
import 'package:chronospin/features/history/presentation/providers/history_providers.dart';
import 'package:chronospin/features/history/domain/solve.dart';
import 'package:chronospin/features/profile/presentation/pages/profile_page.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';
import 'package:chronospin/features/timer/presentation/widgets/scramble_net.dart';
import 'package:chronospin/features/timer/presentation/widgets/timer_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class TimerPage extends ConsumerStatefulWidget {
  const TimerPage({super.key});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  Timer? _ticker;
  Timer? _inspectionTicker; // Add inspection ticker
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleHoldStart() {
    final state = ref.read(timerStateProvider);
    final inspectionSettings = ref.read(inspectionSettingsProvider);

    // If IDLE and Inspection is ENABLED, Hold does NOTHING (wait for tap)
    if (state == TimerState.idle) {
      if (!inspectionSettings.enabled) {
        ref.read(timerStateProvider.notifier).setReady();
        HapticFeedback.lightImpact();
      }
      // If enabled, do nothing. Must tap first.
    }
    // If we are currently INSPECTING, hold prepares the timer
    else if (state == TimerState.inspection) {
      ref.read(timerStateProvider.notifier).setReady();
      HapticFeedback.lightImpact();
    }
  }

  void _handleHoldEnd() {
    final currentState = ref.read(timerStateProvider);
    if (currentState == TimerState.ready) {
      // Start Timer

      // Stop inspection ticker if it was running
      _inspectionTicker?.cancel();

      ref.read(timerStateProvider.notifier).setRunning();
      ref.read(stopWatchProvider).reset();
      ref.read(stopWatchProvider).start();
      _startTicker();
    } else {
      // Aborted hold
      // If we were inspecting, go back to inspection? Or Idle?
      // Usually aborting a hold during inspection just keeps inspection running?
      // But for simplicity, let's revert to previous state logic.
      // If the user lifts finger early, they are effectively still inspecting if time remains.
      // However, our notifier just has 'setIdle', 'setReady'.
      // If we abort 'Ready', we need to check if we came from Inspection.

      // Simplified: If we were ready, and we abort, we go back to IDLE (penalty/reset)
      // OR back to inspection if time remains.
      // The current implementation sets Idle. Let's keep it simple for now and set Idle used in _handleHoldEnd.
      // But verify logic:
      // If I am in Inspection -> Hold (Ready) -> Release Early (Not Ready).
      // Ideally I should go back to Inspection.
      // For now, let's just go to Idle to reset.

      // If we were effectively in inspection (before ready was set), we are still in inspection.
      // We only change to Ready on hold start.

      final wasInspecting = _inspectionTicker?.isActive ?? false;
      if (wasInspecting) {
        ref.read(timerStateProvider.notifier).setInspection();
      } else {
        ref.read(timerStateProvider.notifier).setIdle();
      }
    }
  }

  void _handleTap() {
    final state = ref.read(timerStateProvider);
    final inspectionSettings = ref.read(inspectionSettingsProvider);

    if (state == TimerState.idle) {
      // Check for inspection
      if (inspectionSettings.enabled) {
        _startInspection();
      }
      // If not enabled, tap does nothing (must hold)
    } else if (state == TimerState.inspection) {
      // Tapping during inspection -> Abort/Reset?
      // Usually acts as DNF or Reset.
      _inspectionTicker?.cancel();
      ref.read(timerStateProvider.notifier).setIdle();
      ref.read(inspectionTimeProvider.notifier).state = 0;
    } else if (state == TimerState.running) {
      // Stop Timer
      final stopwatch = ref.read(stopWatchProvider);
      stopwatch.stop();
      _ticker?.cancel();
      ref.read(timerStateProvider.notifier).setStopped();

      // Record time
      final elapsed = stopwatch.elapsed;
      final scramble = ref.read(scrambleProvider);

      final solve = Solve(
        time: elapsed,
        scramble: scramble,
        timestamp: DateTime.now(),
        puzzle: ref.read(puzzleProvider),
      );

      ref.read(historyProvider.notifier).addSolve(solve);
    } else if (state == TimerState.stopped) {
      ref.read(timerStateProvider.notifier).setIdle();
      ref.read(elapsedTimeProvider.notifier).state = Duration.zero;

      // Generate new scramble
      ref.invalidate(scrambleProvider);
    }
  }

  void _startInspection() {
    ref.read(timerStateProvider.notifier).setInspection();
    final duration = ref.read(inspectionSettingsProvider).duration;
    ref.read(inspectionTimeProvider.notifier).state = duration;

    _inspectionTicker?.cancel();
    _inspectionTicker = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(inspectionTimeProvider);
      final next = current - 1;

      if (next < -2) {
        // DNF TRIGGER
        timer.cancel();

        final scramble = ref.read(scrambleProvider);
        final solve = Solve(
          time: Duration.zero,
          scramble: scramble,
          timestamp: DateTime.now(),
          penalty: Penalty.dnf,
          puzzle: ref.read(puzzleProvider),
        );
        ref.read(historyProvider.notifier).addSolve(solve);

        // Reset state
        ref.read(timerStateProvider.notifier).setIdle();
        ref.read(elapsedTimeProvider.notifier).state =
            Duration.zero; // Reset display
        ref.invalidate(scrambleProvider);
      } else {
        ref.read(inspectionTimeProvider.notifier).state = next;
      }
    });
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final stopwatch = ref.read(stopWatchProvider);
      if (stopwatch.isRunning) {
        ref.read(elapsedTimeProvider.notifier).state = stopwatch.elapsed;
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _inspectionTicker?.cancel();
    _inspectionTicker?.cancel();
    super.dispose();
  }

  void _resetTimer() {
    _ticker?.cancel();
    _inspectionTicker?.cancel();
    ref.read(stopWatchProvider).stop();
    ref.read(stopWatchProvider).reset();

    ref.read(timerStateProvider.notifier).setIdle();
    ref.read(elapsedTimeProvider.notifier).state = Duration.zero;
    ref.read(inspectionTimeProvider.notifier).state = 0;
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateProvider);
    final isFocusMode =
        timerState == TimerState.running ||
        timerState == TimerState.inspection ||
        timerState == TimerState.ready;
    final currentScramble = ref.watch(scrambleProvider);
    final themeAccent = ref.watch(themeProvider).accent.color;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.black, // Ensure pure black
      body: PopScope(
        canPop: !isFocusMode,
        onPopInvoked: (didPop) {
          if (didPop) {
            // System handled the pop (we allowed it, so it exited app or popped route)
            return;
          }

          // If we are here, pop was blocked because timer is active.
          // We reset the timer instead.
          _resetTimer();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onLongPressDown: (_) => _handleHoldStart(),
          onLongPressUp: _handleHoldEnd,
          onTap: _handleTap,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.transparent, // Explicitly transparent to catch hits
            child: Column(
              children: [
                // 1. Top UI Section
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isFocusMode ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isFocusMode,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Row 1: Profile & Settings
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () =>
                                      _scaffoldKey.currentState?.openDrawer(),
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardTheme.color,
                                    child: const Icon(
                                      Icons.settings,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ProfilePage(),
                                      ),
                                    );
                                  },
                                  child: CircleAvatar(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).cardTheme.color,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Row 2: Scramble Text
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentScramble,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 18,
                                        color: Colors.white70,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      ref.invalidate(scrambleProvider);
                                    },
                                    child: Icon(
                                      Icons.refresh,
                                      size: 20,
                                      color: themeAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const ScrambleNet(
                              stickerSize: 10.0,
                              gap: 1.3,
                              faceGap: 4.5,
                              alignment: Alignment.centerLeft,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // 2. Timer Center - Independent of other UI
                const Expanded(child: Center(child: TimerDisplay())),

                // History Action Button
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isFocusMode ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isFocusMode,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20, left: 20),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FloatingActionButton.small(
                          heroTag: "history",
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HistoryPage(),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFF1E1E1E),
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.history),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Stats Sheet
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isFocusMode ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isFocusMode,
                    child: GestureDetector(
                      onTap: () {}, // Absorb taps to prevent timer interaction
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(bottom: 30),
                        decoration: const BoxDecoration(
                          color: Color(0xFF121212),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 12),
                            // Handle
                            Container(
                              height: 4,
                              width: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Quick Stats Heading (Non-clickable)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "QUICK STATS",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.bar_chart,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    final stats = ref.watch(
                                      sessionStatsProvider,
                                    );
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _StatItem(
                                          label: "PB",
                                          value: stats['PB'] ?? '-',
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ), // Spacing manually since we are inside a Row inside a Row
                                        _StatItem(
                                          label: "Ao5",
                                          value: stats['Ao5'] ?? '-',
                                        ),
                                        const SizedBox(width: 20),
                                        _StatItem(
                                          label: "Ao12",
                                          value: stats['Ao12'] ?? '-',
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
