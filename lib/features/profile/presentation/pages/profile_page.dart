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
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ao100: 7.45s",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "-0.3s",
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 10),
                                FlSpot(1, 9.5),
                                FlSpot(2, 9),
                                FlSpot(3, 8.5),
                                FlSpot(4, 7.8),
                                FlSpot(5, 7.45),
                              ],
                              isCurved: true,
                              color: accentColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              belowBarData: BarAreaData(
                                show: true,
                                color: accentColor.withOpacity(0.1),
                              ),
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. Activity Heatmap (Visual Placeholder)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
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
                          ),
                        ),
                        Text(
                          "LAST 90 DAYS",
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Simple grid of boxes
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: List.generate(84, (index) {
                        return Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(
                              (index % 5) * 0.2 + 0.1,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),

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
