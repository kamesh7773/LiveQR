import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Glass tiles with Live QR's page-type and feature icons drifting behind the login page.
/// Purely decorative: ignores pointers, hidden from screen readers, still under reduced motion.
class FloatingTiles extends HookWidget {
  const FloatingTiles({super.key});

  // (icon, x, y as fractions of the screen, size, bob period in seconds, phase)
  // Placed in the open gaps between the pitch, the scene and the sign-in card (checked at 1440 and 1920 wide).
  static const _tiles = [
    ('glossy-pastel-magic-sparkles-icon', .40, .07, 64.0, 7.0, 0.0),
    ('Blue-Storefront-App-Icon', .56, .10, 72.0, 8.0, .3),
    ('glossy-orange-analytics-app-icon', .53, .80, 62.0, 6.0, .8),
    ('glossy-blue-qr-code-app-icon', .46, .95, 56.0, 6.0, .6),
    ('Minimal-Coral-Cutlery-Icon', .05, .86, 62.0, 7.0, .45),
    ('Minimalist-Pink-Calendar-App-Icon', .22, .95, 52.0, 8.0, .15),
  ];

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final clock = useAnimationController(
      duration: const Duration(seconds: 336),
    );
    useEffect(() {
      reduceMotion ? clock.stop() : clock.repeat();
      return null;
    }, [reduceMotion]);

    return IgnorePointer(
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, c) => AnimatedBuilder(
            animation: clock,
            builder: (context, _) {
              // 336s is a multiple of every bob (6–8s) and sway (12–16s) period: no jump on wrap.
              final seconds = clock.value * 336;
              return Stack(
                children: [
                  for (final (icon, x, y, size, period, phase) in _tiles)
                    Positioned(
                      left: c.maxWidth * x - size / 2,
                      top: c.maxHeight * y - size / 2,
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          math.sin((seconds / period + phase) * 2 * math.pi) *
                              10,
                        ),
                        child: Transform.rotate(
                          angle:
                              math.sin(
                                (seconds / (period * 2) + phase) * 2 * math.pi,
                              ) *
                              .08,
                          child: _Tile(icon: icon, size: size),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.size});

  final String icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .1),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .55),
        borderRadius: BorderRadius.circular(size * .3),
        border: Border.all(color: Colors.white.withValues(alpha: .9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .18),
            blurRadius: 30,
            offset: const Offset(0, 14),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Image.asset('assets/images/optimized/$icon.png'),
    );
  }
}
