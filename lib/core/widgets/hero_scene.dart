import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../theme/app_colors.dart';
import 'living_qr.dart';
import 'phone_preview.dart';

/// The 3D hero: a living QR card beaming into a floating phone that shows [screen].
/// Rests straight and tilts toward the pointer only while hovered; bobs gently.
/// Holds still under reduced motion.
class HeroScene extends HookWidget {
  const HeroScene({
    super.key,
    required this.screen,
    required this.qrData,
    required this.qrLabel,
    this.badge,
    this.toasts = const [],
  });

  final Widget screen;
  final String qrData;
  final String qrLabel;

  /// Small pill over the phone, e.g. "EXAMPLE".
  final String? badge;
  final List<Widget> toasts;

  /// Layout size of the scene; it is scaled to the space it gets.
  static const size = Size(560, 640);

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pointer = useState(Offset.zero);
    final clock = useAnimationController(
      duration: const Duration(seconds: 168),
    );
    useEffect(() {
      reduceMotion ? clock.stop() : clock.repeat();
      return null;
    }, [reduceMotion]);

    return MouseRegion(
      onHover: reduceMotion
          ? null
          : (e) {
              final box = context.findRenderObject() as RenderBox;
              final local = box.globalToLocal(e.position);
              pointer.value = Offset(
                local.dx / box.size.width - .5,
                local.dy / box.size.height - .5,
              );
            },
      onExit: (_) => pointer.value = Offset.zero,
      child: AspectRatio(
        aspectRatio: size.width / size.height,
        child: FittedBox(
          child: SizedBox.fromSize(
            size: size,
            child: TweenAnimationBuilder<Offset>(
              tween: Tween(end: pointer.value),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (context, p, child) => Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .0009)
                  ..rotateY(_rad(p.dx * 24))
                  ..rotateX(_rad(-p.dy * 16)),
                child: _Layers(pointer: p, clock: clock, scene: this),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _rad(double deg) => deg * math.pi / 180;

class _Layers extends StatelessWidget {
  const _Layers({
    required this.pointer,
    required this.clock,
    required this.scene,
  });

  final Offset pointer;
  final Animation<double> clock;
  final HeroScene scene;

  /// Nearer layers drift further with the pointer, which reads as depth.
  Offset _depth(double z) => pointer * z;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Halo behind everything.
        Positioned(
          left: 10,
          top: 60,
          child: Container(
            width: 540,
            height: 540,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFA78BFA).withValues(alpha: .5),
                  const Color(0xFF93C5FD).withValues(alpha: .22),
                  const Color(0xFF93C5FD).withValues(alpha: 0),
                ],
                stops: const [0, .45, .7],
              ),
            ),
          ),
        ),
        Positioned(
          right: 34,
          top: 40,
          child: _Float(
            clock: clock,
            period: 7,
            offset: _depth(-12),
            child: PhoneFrame(width: 270, screen: scene.screen),
          ),
        ),
        Positioned(
          left: 220,
          top: 296,
          child: _Float(
            clock: clock,
            period: 7,
            phase: .5,
            offset: _depth(18),
            child: _Beam(clock: clock),
          ),
        ),
        Positioned(
          left: 12,
          top: 190,
          child: _Float(
            clock: clock,
            period: 7,
            phase: .5,
            offset: _depth(30),
            child: _QrCard(data: scene.qrData, label: scene.qrLabel),
          ),
        ),
        if (scene.badge case final badge?)
          Positioned(
            right: 196,
            top: 150,
            child: _Float(
              clock: clock,
              period: 6,
              offset: _depth(26),
              child: _Badge(badge),
            ),
          ),
        if (scene.toasts.isNotEmpty)
          Positioned(
            left: 46,
            top: 66,
            child: _Float(
              clock: clock,
              period: 8,
              phase: .25,
              offset: _depth(22),
              child: scene.toasts.first,
            ),
          ),
        if (scene.toasts.length > 1)
          Positioned(
            right: 0,
            top: 474,
            child: _Float(
              clock: clock,
              period: 6,
              phase: .15,
              offset: _depth(34),
              child: scene.toasts[1],
            ),
          ),
      ],
    );
  }
}

/// Bobs [child] up and down by 7px over [period] seconds, shifted by [offset].
class _Float extends StatelessWidget {
  const _Float({
    required this.clock,
    required this.period,
    required this.child,
    this.phase = 0,
    this.offset = Offset.zero,
  });

  final Animation<double> clock;
  final double period;
  final double phase;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: clock,
      child: child,
      builder: (context, child) {
        final seconds =
            clock.value *
            168; // 168s is a multiple of every period here (6, 7, 8, 1.2), so no jump on wrap
        final bob = math.sin((seconds / period + phase) * 2 * math.pi) * 7;
        return Transform.translate(
          offset: offset + Offset(0, bob),
          child: child,
        );
      },
    );
  }
}

class _QrCard extends StatelessWidget {
  const _QrCard({required this.data, required this.label});

  final String data;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .35),
            blurRadius: 70,
            offset: const Offset(0, 40),
            spreadRadius: -28,
          ),
          BoxShadow(
            color: AppColors.violet.withValues(alpha: .3),
            blurRadius: 60,
            spreadRadius: -14,
          ),
        ],
      ),
      child: Column(
        children: [
          LivingQr(data: data, size: 194),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: .25),
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Dashed light that flows from the QR card to the phone.
class _Beam extends StatelessWidget {
  const _Beam({required this.clock});

  final Animation<double> clock;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(70, 64), painter: _BeamPainter(clock));
}

class _BeamPainter extends CustomPainter {
  _BeamPainter(this.clock) : super(repaint: clock);

  final Animation<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final curve = Path()
      ..moveTo(0, h * .66)
      ..cubicTo(w * .3, h * .1, w * .7, h * .9, w, h * .33);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [Color(0xFF60A5FA), Color(0xFFE879F9)],
      ).createShader(Offset.zero & size);
    // 6px dashes with 10px gaps, marching toward the phone.
    final shift = (clock.value * 168 / 1.2 % 1) * 16;
    for (final metric in curve.computeMetrics()) {
      for (var d = shift - 16; d < metric.length; d += 16) {
        final start = math.max(0.0, d);
        final end = math.min(metric.length, d + 6);
        if (end > start) canvas.drawPath(metric.extractPath(start, end), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BeamPainter old) => false;
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: .35),
            blurRadius: 24,
            offset: const Offset(0, 10),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: Color(0xFF6D28D9),
        ),
      ),
    );
  }
}

/// Small frosted note floating in the scene.
class SceneToast extends StatelessWidget {
  const SceneToast({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .3),
            blurRadius: 40,
            offset: const Offset(0, 20),
            spreadRadius: -20,
          ),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        child: child,
      ),
    );
  }
}

class PulseDot extends HookWidget {
  const PulseDot({super.key});

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final ping = useAnimationController(
      duration: const Duration(milliseconds: 1800),
    );
    useEffect(() {
      reduceMotion ? ping.stop() : ping.repeat();
      return null;
    }, [reduceMotion]);
    return AnimatedBuilder(
      animation: ping,
      builder: (context, _) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: const Color(0xFF22C55E),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF22C55E,
              ).withValues(alpha: .55 * (1 - ping.value)),
              spreadRadius: 12 * ping.value,
            ),
          ],
        ),
      ),
    );
  }
}
