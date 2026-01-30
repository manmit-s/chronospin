import 'package:chronospin/core/theme/app_theme.dart';
import 'package:chronospin/features/history/domain/solve.dart';
import 'package:chronospin/features/history/presentation/providers/history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final stats = ref.watch(sessionStatsProvider);
    final themeAccent = ref.watch(themeProvider).accent.color;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("History"),
        actions: [
          IconButton(
            onPressed: () {
              // Confirm Clear
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Clear Session?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(historyProvider.notifier).clearSession();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Clear",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Header Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn("PB", stats["PB"] ?? '-', themeAccent),
                _buildContainerLine(),
                _buildStatColumn(
                  "Ao5",
                  stats["Ao5"] ?? '-',
                  Colors.greenAccent,
                ),
                _buildContainerLine(),
                _buildStatColumn(
                  "Ao12",
                  stats["Ao12"] ?? '-',
                  Colors.orangeAccent,
                ),
                _buildContainerLine(),
                _buildStatColumn("Count", stats["Count"] ?? '0', Colors.white),
              ],
            ),
          ),

          // List Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text("#", style: TextStyle(color: Colors.grey)),
                ),
                Expanded(
                  child: Text("Time", style: TextStyle(color: Colors.grey)),
                ),
                Text("Scramble", style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

          // Solves List
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: Colors.grey[800]),
                        const SizedBox(height: 16),
                        Text(
                          "No solves yet",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(historyProvider.notifier)
                                .generateRandomSolves();
                          },
                          child: const Text("Generate Demo Data"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: history.length,
                    padding: const EdgeInsets.only(bottom: 80),
                    itemBuilder: (context, index) {
                      final solve = history[index];
                      // Reverse index display (Total - index)
                      final displayIndex = history.length - index;

                      return Dismissible(
                        key: Key(solve.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(historyProvider.notifier)
                              .deleteSolve(solve.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white10),
                            ),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 30,
                                child: Text(
                                  "$displayIndex",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  _formatDuration(solve.effectiveTime),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: solve.penalty == Penalty.dnf
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    solve.scramble,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    DateFormat.Hm().format(solve.timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContainerLine() {
    return Container(height: 30, width: 1, color: Colors.white10);
  }

  String _formatDuration(Duration d) {
    int min = d.inMinutes;
    int sec = d.inSeconds % 60;
    int centi = (d.inMilliseconds % 1000) ~/ 10;

    if (min > 0) {
      return "$min:${sec.toString().padLeft(2, '0')}.${centi.toString().padLeft(2, '0')}";
    }
    return "$sec.${centi.toString().padLeft(2, '0')}";
  }
}
