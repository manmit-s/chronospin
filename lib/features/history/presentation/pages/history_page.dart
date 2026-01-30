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
                  backgroundColor: const Color(0xFF1E1E1E),
                  title: const Text(
                    "Clear Session?",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "This cannot be undone.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
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
                _buildStatColumn("Ao5", stats["Ao5"] ?? '-', themeAccent),
                _buildContainerLine(),
                _buildStatColumn("Ao12", stats["Ao12"] ?? '-', themeAccent),
                _buildContainerLine(),
                _buildStatColumn("Count", stats["Count"] ?? '0', Colors.white),
              ],
            ),
          ),

          // Times Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(
                  "TIMES",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const Spacer(),
                Icon(Icons.sort, color: Colors.grey[800], size: 20),
              ],
            ),
          ),

          // Solves Grid
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
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.6,
                        ),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final solve = history[index];
                      // Different layout from reference: cleaner, glass-ish look
                      return GestureDetector(
                        onTap: () => _showSolveDetailsDialog(
                          context,
                          ref,
                          solve,
                          themeAccent,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.05),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Subtle Accent Indicator
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: solve.penalty == Penalty.dnf
                                        ? Colors.red
                                        : themeAccent.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                              // Date (Top Right now for differentiation)
                              Positioned(
                                top: 8,
                                right: 12,
                                child: Text(
                                  DateFormat('d/M').format(solve.timestamp),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              // Time Centered & Large
                              Center(
                                child: Text(
                                  _formatDuration(solve.effectiveTime),
                                  style: TextStyle(
                                    color: solve.penalty == Penalty.dnf
                                        ? Colors.red
                                        : Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              // Penalty Text Bottom Center
                              if (solve.penalty == Penalty.plus2)
                                Positioned(
                                  bottom: 6,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      "+2",
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
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

  void _showSolveDetailsDialog(
    BuildContext context,
    WidgetRef ref,
    Solve solve,
    Color accentColor,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: _SolveDetailsContent(solve: solve, accentColor: accentColor),
        );
      },
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

class _SolveDetailsContent extends ConsumerStatefulWidget {
  final Solve solve;
  final Color accentColor;

  const _SolveDetailsContent({required this.solve, required this.accentColor});

  @override
  ConsumerState<_SolveDetailsContent> createState() =>
      _SolveDetailsContentState();
}

class _SolveDetailsContentState extends ConsumerState<_SolveDetailsContent> {
  bool _isScrambleExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Watch current solve state to see live updates if we modify it
    // Or we can just modify via buttons and rely on parent reload.
    // Ideally we might want a local state or ref.watch specific to ID if granular updates needed.
    // For simplicity, we just use the passed solve, but since we modify it, we should verify logic.
    // Actually, when we update provider, the history list updates, which rebuilds the grid.
    // But this Dialog is open. To see updates LIVE in the dialog, we need to find the solve in the updated history.

    final history = ref.watch(historyProvider);
    final currentSolve = history.firstWhere(
      (s) => s.id == widget.solve.id,
      orElse: () => widget
          .solve, // Fallback if deleted (should close dialog then ideally)
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Theme oriented background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Time + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _formatDuration(currentSolve.effectiveTime),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: currentSolve.penalty == Penalty.dnf
                      ? Colors.red
                      : Colors.white,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(currentSolve.timestamp),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    DateFormat('HH:mm').format(currentSolve.timestamp),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey[800]),

          // Scramble Section
          InkWell(
            onTap: () {
              setState(() {
                _isScrambleExpanded = !_isScrambleExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Icon(Icons.casino, color: widget.accentColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentSolve.scramble,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      maxLines: _isScrambleExpanded ? 10 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isScrambleExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          if (_isScrambleExpanded) ...[
            const SizedBox(height: 10),
            // Placeholder for Scramble Net
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                "2D SCRAMBLE NET",
                style: TextStyle(
                  color: Colors.grey.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Divider(color: Colors.grey[800]),
          const SizedBox(height: 10),

          // Actions / Flags
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Penalty Toggles
              Row(
                children: [
                  _PenaltyButton(
                    label: "+2",
                    isActive: currentSolve.penalty == Penalty.plus2,
                    onTap: () {
                      final newPenalty = currentSolve.penalty == Penalty.plus2
                          ? Penalty.none
                          : Penalty.plus2;
                      _updateSolve(currentSolve.copyWith(penalty: newPenalty));
                    },
                  ),
                  const SizedBox(width: 8),
                  _PenaltyButton(
                    label: "DNF",
                    isActive: currentSolve.penalty == Penalty.dnf,
                    isDnf: true,
                    onTap: () {
                      final newPenalty = currentSolve.penalty == Penalty.dnf
                          ? Penalty.none
                          : Penalty.dnf;
                      _updateSolve(currentSolve.copyWith(penalty: newPenalty));
                    },
                  ),
                ],
              ),

              // Action Buttons
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.grey),
                    onPressed: () {
                      // TODO: Edit Notes
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      ref
                          .read(historyProvider.notifier)
                          .deleteSolve(currentSolve.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateSolve(Solve updated) {
    ref.read(historyProvider.notifier).updateSolve(updated);
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

class _PenaltyButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDnf;

  const _PenaltyButton({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isDnf = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDnf ? Colors.red : Colors.orange;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isActive ? color : Colors.grey[700]!),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
