import 'package:chronospin/features/algorithms/presentation/pages/algorithms_page.dart';
import 'package:chronospin/features/timer/presentation/pages/timer_page.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Banner Space
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E),
              // Optional: Add a subtle gradient or pattern
            ),
            child: Stack(
              children: [
                // Abstract background shape placeholder
                Positioned(
                  right: -20,
                  top: -20,
                  child: Opacity(
                    opacity: 0.1,
                    child: Icon(Icons.timer, size: 150, color: Colors.white),
                  ),
                ),
                // Logo/Brand
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.grid_4x4, // Cube-like icon
                          color: primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "ChronoSpin",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Navigation
          _DrawerItem(
            icon: Icons.timer_outlined,
            label: "Timer",
            isSelected: true, // Assuming we are primarily on Timer for now
            onTap: () {
              Navigator.pop(context); // Close drawer
              // Check if we are already on TimerPage to avoid push
              // Since this is a simple app, we might just look at context.widget runtimeType
              // or just pop if we assume this drawer is mostly used from TimerPage.
              // For robustness, we check if we can pop to root or replace.
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const TimerPage()),
                  (route) => false,
                );
              }
            },
          ),

          _DrawerItem(
            icon: Icons.grid_on, // Or library_books
            label: "Algorithms",
            isSelected: false,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AlgorithmsPage()),
              );
            },
          ),

          const Divider(thickness: 0.5, color: Colors.white10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Puzzle Type",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),

          Consumer(
            builder: (context, ref, _) {
              final current = ref.watch(puzzleProvider);
              return ListTile(
                leading: const Icon(Icons.extension, color: Colors.white),
                title: Text(
                  current.label,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.white54,
                ),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xFF1E1E1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (ctx) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...PuzzleType.values.map(
                            (p) => ListTile(
                              title: Text(
                                p.label,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: p == current
                                  ? Icon(Icons.check, color: theme.primaryColor)
                                  : null,
                              onTap: () {
                                ref.read(puzzleProvider.notifier).state = p;
                                ref.invalidate(scrambleProvider);
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Timer Settings",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),

          // Inspection Settings
          Consumer(
            builder: (context, ref, _) {
              final settings = ref.watch(inspectionSettingsProvider);
              return Column(
                children: [
                  SwitchListTile(
                    title: const Text(
                      "Inspection",
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: const Text(
                      "Enable inspection time",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    value: settings.enabled,
                    onChanged: (val) {
                      ref
                          .read(inspectionSettingsProvider.notifier)
                          .setEnabled(val);
                    },
                    activeColor: theme.primaryColor,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  if (settings.enabled)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Duration (s)",
                            style: TextStyle(color: Colors.white),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 60,
                            child: TextFormField(
                              initialValue: settings.duration.toString(),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                              ),
                              onChanged: (val) {
                                if (val.isNotEmpty) {
                                  final duration = int.tryParse(val);
                                  if (duration != null) {
                                    ref
                                        .read(
                                          inspectionSettingsProvider.notifier,
                                        )
                                        .setDuration(duration);
                                  }
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Text(
              "Other",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),

          _DrawerItem(
            icon: Icons.folder_open_outlined,
            label: "Export/Import",
            enabled: false,
            onTap: () {},
          ),

          const Divider(thickness: 0.5, color: Colors.white10),

          _DrawerItem(
            icon: Icons.favorite_border,
            label: "Donate",
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement Donate
            },
          ),

          _DrawerItem(
            icon: Icons.help_outline,
            label: "About and feedback",
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement About
            },
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;
  final bool enabled;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = enabled
        ? (isSelected ? theme.primaryColor : Colors.white)
        : Colors.white38;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
        leading: Icon(icon, color: color),
        title: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
