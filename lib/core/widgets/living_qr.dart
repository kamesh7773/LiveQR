import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:qr/qr.dart';

import '../theme/app_colors.dart';

/// A scannable QR code for [data], drawn with rounded brand-gradient modules
/// and a light sweep that runs across it (still when reduced motion is on).
class LivingQr extends HookWidget {
  const LivingQr({super.key, required this.data, this.size = 200});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) {
    final shape = useMemoized(() => qrModulePath(data), [data]);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final sweep = useAnimationController(
      duration: const Duration(milliseconds: 4500),
    );
    useEffect(() {
      reduceMotion ? sweep.stop() : sweep.repeat();
      return null;
    }, [reduceMotion]);

    return Semantics(
      label: 'QR code',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _QrPainter(shape, sweep, reduceMotion)),
      ),
    );
  }
}

/// Module path in QR units (one unit per module, plus a one-module margin).
@visibleForTesting
({Path path, int units}) qrModulePath(String data) {
  final image = QrImage(
    QrCode(
      payload: QrPayload.fromString(data),
      errorCorrectLevel: QrErrorCorrectLevel.high,
    ),
  );
  final n = image.moduleCount;
  bool inFinder(int x, int y) =>
      (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);

  final path = Path()..fillType = PathFillType.evenOdd;
  for (var y = 0; y < n; y++) {
    for (var x = 0; x < n; x++) {
      if (!image.isDark(y, x) || inFinder(x, y)) continue;
      path.addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 1.08, y + 1.08, .84, .84),
          const Radius.circular(.3),
        ),
      );
    }
  }
  // Finder patterns: rounded ring with a rounded centre (even-odd fill cuts the ring).
  for (final (fx, fy) in [(0, 0), (n - 7, 0), (0, n - 7)]) {
    final o = Offset(fx + 1.0, fy + 1.0);
    path
      ..addRRect(
        RRect.fromRectAndRadius(
          o & const Size(7, 7),
          const Radius.circular(2.2),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          (o + const Offset(1, 1)) & const Size(5, 5),
          const Radius.circular(1.4),
        ),
      )
      ..addRRect(
        RRect.fromRectAndRadius(
          (o + const Offset(2, 2)) & const Size(3, 3),
          const Radius.circular(.9),
        ),
      );
  }
  return (path: path, units: n + 2);
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.shape, this.sweep, this.still) : super(repaint: sweep);

  final ({Path path, int units}) shape;
  final Animation<double> sweep;
  final bool still;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / shape.units;
    canvas.scale(scale);
    final bounds = Offset.zero & Size.square(shape.units.toDouble());

    canvas.drawPath(
      shape.path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), AppColors.violet, AppColors.magenta],
          stops: [0, .55, 1],
        ).createShader(bounds),
    );
    if (still) return;

    // A white band sliding diagonally from before the top-left to past the bottom-right.
    final p = -.2 + sweep.value * 1.4;
    double s(double v) => math.min(1, math.max(0, v));
    canvas.drawPath(
      shape.path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: .8),
            Colors.white.withValues(alpha: 0),
          ],
          stops: [s(p - .12), s(p), s(p + .12)],
        ).createShader(bounds),
    );
  }

  @override
  bool shouldRepaint(_QrPainter old) =>
      old.shape != shape || old.still != still;
}
