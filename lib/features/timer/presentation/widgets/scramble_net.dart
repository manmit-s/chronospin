import 'package:cuber/cuber.dart' as cuber;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chronospin/features/timer/domain/puzzle_type.dart';
import 'package:chronospin/features/timer/presentation/providers/timer_providers.dart';

class ScrambleNet extends ConsumerWidget {
  final double? stickerSize;
  final double? gap;
  final double? faceGap;
  final AlignmentGeometry alignment;

  const ScrambleNet({
    super.key,
    this.stickerSize,
    this.gap,
    this.faceGap,
    this.alignment = Alignment.center,
  });

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

    List<cuber.Color>? colors;
    if (puzzle == PuzzleType.cube3x3 && scramble.isNotEmpty) {
      try {
        final cube = cuber.Algorithm.parse(scramble).apply(cuber.Cube.solved);
        colors = cube.colors;
      } catch (_) {}
    }

    final resolvedColors = colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double resolvedGap = gap ?? 2.0;
        final double resolvedFaceGap = faceGap ?? (resolvedGap * 3.0);
        final double resolvedStickerSize =
            stickerSize ?? _computeStickerSize(constraints.maxWidth, resolvedGap, resolvedFaceGap);
        final totalW = 12 * resolvedStickerSize + 8 * resolvedGap + 3 * resolvedFaceGap;
        final totalH = 9 * resolvedStickerSize + 6 * resolvedGap + 2 * resolvedFaceGap;

        const paddingValue = 8.0;

        if (resolvedColors == null) {
          return _Placeholder(
            width: totalW,
            height: totalH,
            alignment: alignment,
            padding: paddingValue,
          );
        }

        return Align(
          alignment: alignment,
          child: Container(
            width: totalW + 2 * paddingValue,
            height: totalH + 2 * paddingValue,
            padding: const EdgeInsets.all(paddingValue),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CustomPaint(
                size: Size(totalW, totalH),
                painter: _NetPainter(
                  colors: resolvedColors,
                  stickerSize: resolvedStickerSize,
                  gap: resolvedGap,
                  faceGap: resolvedFaceGap,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static double _computeStickerSize(double availableWidth, double gap, double faceGap) {
    return ((availableWidth - 8 * gap - 3 * faceGap - 16) / 12).clamp(10.0, 28.0);
  }
}

class _NetPainter extends CustomPainter {
  final List<cuber.Color> colors;
  final double stickerSize;
  final double gap;
  final double faceGap;

  _NetPainter({
    required this.colors,
    required this.stickerSize,
    required this.gap,
    required this.faceGap,
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
    final fg = faceGap;

    for (final (col, row, offset) in ScrambleNet._faceLayout) {
      for (int sy = 0; sy < 3; sy++) {
        for (int sx = 0; sx < 3; sx++) {
          final idx = offset + sy * 3 + sx;
          final cuberColor = colors[idx];
          final flutterColor = ScrambleNet._stickerColors[cuberColor]!;

          final x = col * (3 * s + 2 * g + fg) + sx * (s + g);
          final y = row * (3 * s + 2 * g + fg) + sy * (s + g);

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
      colors != oldDelegate.colors ||
      stickerSize != oldDelegate.stickerSize ||
      gap != oldDelegate.gap ||
      faceGap != oldDelegate.faceGap;
}

class _Placeholder extends StatelessWidget {
  final double width;
  final double height;
  final AlignmentGeometry alignment;
  final double padding;

  const _Placeholder({
    required this.width,
    required this.height,
    required this.alignment,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        height: height + 2 * padding,
        width: width + 2 * padding,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          "SCRAMBLE NET",
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.3),
            fontSize: (height * 0.1).clamp(6.0, 10.0),
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
