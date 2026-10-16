import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../theme/app_colors.dart';

/// Light page ground with three soft pastel lights drifting behind [child].
/// The lights hold still when the platform asks for reduced motion.
class AuroraBackground extends HookWidget {
  const AuroraBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final drift = useAnimationController(duration: const Duration(seconds: 24));
    useEffect(() {
      reduceMotion ? drift.stop() : drift.repeat(reverse: true);
      return null;
    }, [reduceMotion]);

    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: AppColors.sky)),
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _AuroraPainter(drift)),
          ),
        ),
        child,
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  _AuroraPainter(this.drift) : super(repaint: drift);

  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeInOut.transform(drift.value);
    final w = size.width, h = size.height;
    final r = w > h ? w : h;
    _light(
      canvas,
      Offset(w * (.08 + .06 * t), h * (.02 + .05 * t)),
      r * .42,
      AppColors.auroraBlue,
    );
    _light(
      canvas,
      Offset(w * (.95 - .06 * t), h * (.12 + .04 * t)),
      r * .40,
      AppColors.auroraLilac,
    );
    _light(
      canvas,
      Offset(w * (.55 + .05 * t), h * (.62 - .05 * t)),
      r * .30,
      AppColors.auroraPink.withValues(alpha: .7),
    );
  }

  void _light(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.drift != drift;
}
