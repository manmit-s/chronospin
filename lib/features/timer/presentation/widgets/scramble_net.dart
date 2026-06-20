import 'package:cuber/cuber.dart' as cuber;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronospin/features/timer/domain/puzzle_type.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';

class ScrambleNet extends ConsumerWidget {
  const ScrambleNet({super.key});

  static const _stickerColors = {
    cuber.Color.up: Color(0xFFFFFFFF),
    cuber.Color.right: Color(0xFFB71234),
    cuber.Color.front: Color(0xFF009E60),
    cuber.Color.down: Color(0xFFFFD500),
    cuber.Color.left: Color(0xFFFF5800),
    cuber.Color.bottom: Color(0xFF0051BA),
  };

  static const _faceLayout = [
    (1, 0, 0),
    (0, 1, 36),
    (1, 1, 18),
    (2, 1, 9),
    (3, 1, 45),
    (1, 2, 27),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puzzle = ref.watch(puzzleProvider);
    final scramble = ref.watch(scrambleProvider);

    if (puzzle != PuzzleType.cube3x3) {
      return const _Placeholder();
    }

    if (scramble.isEmpty) {
      return const _Placeholder();
    }

    List<cuber.Color>? colors;
    try {
      final cube = cuber.Algorithm.parse(scramble).apply(cuber.Cube.solved);
      colors = cube.colors;
    } catch (_) {}

    if (colors == null) {
      return const _Placeholder();
    }

    final resolvedColors = colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 2.0;
        final stickerSize = _computeStickerSize(constraints.maxWidth, gap);
        final totalW = 12 * stickerSize + 11 * gap;
        final totalH = 9 * stickerSize + 8 * gap;

        return Center(
          child: Container(
            width: totalW,
            height: totalH,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                size: Size(totalW, totalH),
                painter: _NetPainter(
                  colors: resolvedColors,
                  stickerSize: stickerSize,
                  gap: gap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static double _computeStickerSize(double availableWidth, double gap) {
    return ((availableWidth - 11 * gap - 16) / 12).clamp(10.0, 28.0);
  }
}

class _NetPainter extends CustomPainter {
  final List<cuber.Color> colors;
  final double stickerSize;
  final double gap;

  _NetPainter({
    required this.colors,
    required this.stickerSize,
    required this.gap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = const Color(0x40000000);

    final s = stickerSize;
    final g = gap;

    for (final (col, row, offset) in ScrambleNet._faceLayout) {
      for (int sy = 0; sy < 3; sy++) {
        for (int sx = 0; sx < 3; sx++) {
          final idx = offset + sy * 3 + sx;
          final cuberColor = colors[idx];
          final flutterColor = ScrambleNet._stickerColors[cuberColor]!;

          final x = (col * 3 + sx) * (s + g);
          final y = (row * 3 + sy) * (s + g);

          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, s, s),
            const Radius.circular(2),
          );

          fillPaint.color = flutterColor;
          canvas.drawRRect(rrect, fillPaint);
          canvas.drawRRect(rrect, strokePaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_NetPainter oldDelegate) =>
      colors != oldDelegate.colors;
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        "SCRAMBLE NET",
        style: TextStyle(
          color: Colors.grey.withValues(alpha: 0.3),
          fontSize: 10,
          letterSpacing: 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
