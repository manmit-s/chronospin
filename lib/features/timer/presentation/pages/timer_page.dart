import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/features/history/presentation/pages/history_page.dart';
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
      ref.read(stopWatchProvider).stop();
      _ticker?.cancel();
      ref.read(timerStateProvider.notifier).setStopped();
      // Record time here (TODO)
      // reset to idle after delay or tap?
    } else if (ref.read(timerStateProvider) == TimerState.stopped) {
      ref.read(timerStateProvider.notifier).setIdle();
      ref.read(elapsedTimeProvider.notifier).state = Duration.zero;
      // Generate new scramble here (TODO)
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
    final currentScramble = ref.watch(scrambleProvider);

    return Scaffold(
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
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Row 1: Profile & Settings
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).cardTheme.color,
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                              ),
                            ),
                            CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).cardTheme.color,
                              child: const Icon(
                                Icons.settings,
                                color: Colors.grey,
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
                                child: const Icon(
                                  Icons.refresh,
                                  size: 20,
                                  color: Colors.yellowAccent,
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

                // Timer fills the remaining space
                const Expanded(child: Center(child: TimerDisplay())),

                // Spacer for Bottom Sheet area
                const SizedBox(height: 180),
              ],
            ),

            // Floating Buttons
            Positioned(
              right: 20,
              bottom: 200,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: "theme",
                    onPressed: () {
                      final current = ref.read(themeProvider).accent;
                      final next =
                          AppAccent.values[(AppAccent.values.indexOf(current) +
                                  1) %
                              AppAccent.values.length];
                      ref.read(themeProvider.notifier).setAccent(next);
                    },
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.palette),
                  ),
                  const SizedBox(height: 16),
                  FloatingActionButton(
                    heroTag: "tools",
                    onPressed: () {},
                    backgroundColor: const Color(0xFF1E1E1E),
                    foregroundColor: Colors.white,
                    child: const Icon(Icons.build),
                  ),
                ],
              ),
            ),

            // Bottom Stats Sheet
            Align(
              alignment: Alignment.bottomCenter,
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
                    // Quick Stats Heading (Clickable)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HistoryPage(),
                          ),
                        );
                      },
                      child: Row(
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
                            Icons.chevron_right,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _StatItem(label: "PB", value: "9.85"),
                        _StatItem(label: "Ao5", value: "14.10"),
                        _StatItem(label: "Ao12", value: "14.45"),
                      ],
                    ),
                  ],
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
