import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/core/presentation/widgets/app_drawer.dart';
import 'package:chronospin/features/history/presentation/pages/history_page.dart';
import 'package:chronospin/features/history/presentation/providers/history_providers.dart';
import 'package:chronospin/features/history/domain/solve.dart';
import 'package:chronospin/features/profile/presentation/pages/profile_page.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _handleHoldStart() {
    if (ref.read(timerStateProvider) == TimerState.idle) {
      ref.read(timerStateProvider.notifier).setReady();
      HapticFeedback.lightImpact();
    }
  }

  void _handleHoldEnd() {
    final currentState = ref.read(timerStateProvider);
    if (currentState == TimerState.ready) {
      // Start Timer
      ref.read(timerStateProvider.notifier).setRunning();
      ref.read(stopWatchProvider).reset();
      ref.read(stopWatchProvider).start();
      _startTicker();
    } else {
      // Aborted hold
      ref.read(timerStateProvider.notifier).setIdle();
    }
  }

  void _handleTap() {
    if (ref.read(timerStateProvider) == TimerState.running) {
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
      );

      ref.read(historyProvider.notifier).addSolve(solve);
    } else if (ref.read(timerStateProvider) == TimerState.stopped) {
      ref.read(timerStateProvider.notifier).setIdle();
      ref.read(elapsedTimeProvider.notifier).state = Duration.zero;

      // Generate new scramble
      ref.invalidate(scrambleProvider);
    }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerStateProvider);
    final isRunning = timerState == TimerState.running;
    final currentScramble = ref.watch(scrambleProvider);
    final themeAccent = ref.watch(themeProvider).accent.color;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: Colors.black, // Ensure pure black
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressDown: (_) => _handleHoldStart(),
        onLongPressUp: _handleHoldEnd,
        onTap: _handleTap,
        child: Stack(
          children: [
            // Main Layout (Top + Timer) - Using Column to prevent overlap
            Column(
              children: [
                // Top Section
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isRunning ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: isRunning,
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
                            const SizedBox(height: 20),
                            // Scramble Net Placeholder
                            Container(
                              height: 140,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                // color: const Color(0xFF101010),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                "SCRAMBLE NET",
                                style: TextStyle(
                                  color: Colors.grey.withOpacity(0.3),
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Timer fills the remaining space
                const Expanded(child: Center(child: TimerDisplay())),

                // Spacer for Bottom Sheet area
                const SizedBox(height: 180),
              ],
            ),

            // History Action Button
            Positioned(
              left: 20,
              bottom: 180,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isRunning ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: isRunning,
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

            // Bottom Stats Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isRunning ? 0.0 : 1.0,
                child: IgnorePointer(
                  ignoring: isRunning,
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
                                  final stats = ref.watch(sessionStatsProvider);
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
            ),
          ],
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
