import 'package:chronospin/features/history/domain/solve.dart';
import 'package:chronospin/features/history/presentation/providers/history_providers.dart';
import 'package:chronospin/features/profile/presentation/providers/profile_providers.dart';
import 'package:chronospin/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileImage = ref.watch(profileImageProvider);
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.color;
    final stats = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header (Avatar + Name)
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final error = await ref
                                .read(profileImageProvider.notifier)
                                .pickImage();

                            if (context.mounted && error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: accentColor,
                                    width: 2,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: profileImage != null
                                      ? FileImage(profileImage)
                                      : const NetworkImage(
                                              'https://i.pravatar.cc/300',
                                            )
                                            as ImageProvider,
                                  backgroundColor: Colors.black,
                                ),
                              ),
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black26,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white30,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            "🇺🇸",
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "SpeedCuber99",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Chip(
                      label: const Text(
                        "PRO MEMBER",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: const Color(0xFF1E1E1E),
                      labelStyle: const TextStyle(color: Colors.greenAccent),
                      avatar: const Icon(
                        Icons.verified,
                        size: 14,
                        color: Colors.greenAccent,
                      ),
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 2. Stats Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _StatCard(
                    title: "TOTAL SOLVES",
                    value: stats["Total"] ?? "0",
                    accent: accentColor,
                  ),
                  _StatCard(
                    title: "PB (SINGLE)",
                    value: stats["PB"] ?? "-",
                    icon: Icons.emoji_events,
                    accent: accentColor,
                  ),
                  _StatCard(
                    title: "Ao5 (BEST)",
                    value: stats["BestAo5"] ?? "-",
                  ),
                  _StatCard(
                    title: "Ao12 (BEST)",
                    value: stats["BestAo12"] ?? "-",
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. Recent Performance Graph
              const _PerformanceGraph(),

              const SizedBox(height: 20),

              const SizedBox(height: 20),

              // 4. Activity Heatmap
              const _ActivityHeatmap(),

              const SizedBox(height: 24),
              const Text(
                "PREFERENCES",
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),

              // 5. Preferences
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Theme",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Dynamic Theme Circles
                        Row(
                          children: AppAccent.values.map((accent) {
                            return GestureDetector(
                              onTap: () {
                                ref
                                    .read(themeProvider.notifier)
                                    .setAccent(accent);
                              },
                              child: _ThemeCircle(
                                color: accent.color,
                                isSelected: themeState.accent == accent,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 6. Cloud Sync
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_done,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Cloud Sync",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Synced 2m ago",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor:
                            themeState.accent == AppAccent.yellow ||
                                themeState.accent == AppAccent.monochrome
                            ? Colors.black
                            : Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {},
                      child: const Text("Sync Now"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? accent;

  const _StatCard({
    required this.title,
    required this.value,
    this.icon,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  color: (accent ?? Colors.yellowAccent).withOpacity(0.5),
                  size: 16,
                ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (accent != null)
                Container(
                  width: 20,
                  height: 3,
                  color: accent,
                  margin: const EdgeInsets.only(top: 4),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ThemeCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  const _ThemeCircle({required this.color, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
      ),
    );
  }
}

class _PerformanceGraph extends ConsumerStatefulWidget {
  const _PerformanceGraph();

  @override
  ConsumerState<_PerformanceGraph> createState() => _PerformanceGraphState();
}

class _PerformanceGraphState extends ConsumerState<_PerformanceGraph> {
  bool _showAo100 = true; // Default to Ao100

  // Helper from history_providers.dart ideally or duplicated
  String formatTime(num millis) {
    int totalMillis = millis.floor();
    int min = (totalMillis ~/ 1000) ~/ 60;
    int sec = (totalMillis ~/ 1000) % 60;
    int centi = (totalMillis % 1000) ~/ 10;
    if (min > 0)
      return "$min:${sec.toString().padLeft(2, '0')}.${centi.toString().padLeft(2, '0')}";
    return "$sec.${centi.toString().padLeft(2, '0')}";
  }

  double? calculateRawAverage(List<Solve> window) {
    // Trim top/bottom 5%
    if (window.isEmpty) return null;

    int trimCount = (window.length * 0.05).ceil();

    final times = window.map((s) {
      if (s.penalty == Penalty.dnf) return 999999999;
      return s.effectiveTime.inMilliseconds;
    }).toList();
    times.sort();

    // Need at least enough solves to trim
    if (times.length <= trimCount * 2) {
      if (times.isEmpty) return null;
      final sum = times.reduce((a, b) => a + b);
      if (sum > 999999000) return null; // Contains DNF
      return sum / times.length;
    }

    final validTimes = times.sublist(trimCount, times.length - trimCount);
    final sum = validTimes.reduce((a, b) => a + b);
    return sum / validTimes.length;
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.color;

    final int count = _showAo100 ? 100 : 50;

    // Get last N solves (Newest first in history, take N, then reverse for graph chronological left-to-right)
    final recentSolves = history.take(count).toList();
    final chronologicalSolves = recentSolves.reversed.toList();

    // Calculate Average for the Header
    final double? currentAvg = calculateRawAverage(recentSolves);
    final String avgDisplay = currentAvg != null ? formatTime(currentAvg) : "-";

    // Prepare Spots
    List<FlSpot> spots = [];
    double minBytes = double.infinity;
    double maxBytes = 0;

    for (int i = 0; i < chronologicalSolves.length; i++) {
      final s = chronologicalSolves[i];
      if (s.penalty != Penalty.dnf) {
        double sec = s.effectiveTime.inMilliseconds / 1000.0;
        spots.add(FlSpot(i.toDouble(), sec));
        if (sec < minBytes) minBytes = sec;
        if (sec > maxBytes) maxBytes = sec;
      }
    }

    // Safety for min/max
    if (minBytes == double.infinity) minBytes = 0;
    if (maxBytes == 0) maxBytes = 10;

    return Container(
      height: 250, // Slightly taller
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Ao$count: ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    avgDisplay,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              // Toggler
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    _ToggleBtn(
                      "50",
                      !_showAo100,
                      () => setState(() => _showAo100 = false),
                      accentColor,
                    ),
                    Container(width: 1, height: 20, color: Colors.white10),
                    _ToggleBtn(
                      "100",
                      _showAo100,
                      () => setState(() => _showAo100 = true),
                      accentColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: spots.isEmpty
                ? const Center(
                    child: Text(
                      "Not enough data",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      minY: (minBytes * 0.9)
                          .floorToDouble(), // Dynamic Range with some padding
                      maxY: (maxBytes * 1.1).ceilToDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.2, // Smoothness
                          color: accentColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                accentColor.withOpacity(0.2),
                                accentColor.withOpacity(0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _ToggleBtn(this.label, this.isSelected, this.onTap, this.activeColor);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        color: isSelected ? activeColor.withOpacity(0.2) : Colors.transparent,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ActivityHeatmap extends ConsumerWidget {
  const _ActivityHeatmap();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final themeState = ref.watch(themeProvider);
    final accentColor = themeState.accent.color;

    // 1. Process Data
    final Map<String, int> density = {};
    for (final solve in history) {
      final key =
          "${solve.timestamp.year}-${solve.timestamp.month.toString().padLeft(2, '0')}-${solve.timestamp.day.toString().padLeft(2, '0')}";
      density[key] = (density[key] ?? 0) + 1;
    }

    // 2. Generate last 91 days
    final now = DateTime.now();
    final days = List.generate(91, (index) {
      return now.subtract(Duration(days: 90 - index));
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "ACTIVITY HEATMAP",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                "LAST 90 DAYS",
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: days.map((date) {
              final key =
                  "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
              final count = density[key] ?? 0;

              double opacity = 0.1;
              if (count > 0) {
                opacity = 0.2 + (count / 20.0).clamp(0.0, 0.8);
              }

              return Tooltip(
                message: "$count solves on $key",
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
