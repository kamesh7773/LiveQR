import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Size every preview is laid out at; [PhoneFrame] scales it to fit.
const _screen = Size(250, 540);

/// A dark phone with a notch showing [screen] (laid out at 250×540 and scaled).
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.width, required this.screen});

  final double width;
  final Widget screen;

  @override
  Widget build(BuildContext context) {
    final height = width * 560 / 270;
    final pad = width * .037;
    final radius = width * .17;
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A3150), AppColors.phoneFrame],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .45),
            blurRadius: 80,
            offset: const Offset(0, 46),
            spreadRadius: -30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - pad),
        child: Stack(
          children: [
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.fill,
                // A miniature picture of a page: system text scaling would only break its layout.
                child: MediaQuery.withNoTextScaling(
                  child: SizedBox.fromSize(size: _screen, child: screen),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: EdgeInsets.only(top: width * .03),
                width: width * .31,
                height: width * .088,
                decoration: BoxDecoration(
                  color: const Color(0xFF05060F),
                  borderRadius: BorderRadius.circular(width),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "The Daily Brew" restaurant page, drawn in widgets.
class MenuPagePreview extends StatelessWidget {
  const MenuPagePreview({super.key});

  static const _cream = Color(0xFFFFFBF5);
  static const _brown = Color(0xFFB45309);
  static const _stone = Color(0xFF78716C);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontFamily: AppTheme.bodyFont,
        color: Color(0xFF1C1917),
      ),
      child: ColoredBox(
        color: _cream,
        child: Column(
          children: [
            SizedBox(
              height: 186,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFD97706),
                          Color(0xFF78350F),
                          Color(0xFF451A03),
                        ],
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment(.6, -.8),
                        radius: .9,
                        colors: [Color(0xCCFCD34D), Color(0x00FCD34D)],
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 34,
                    left: 0,
                    right: 0,
                    child: Center(child: _CoffeeCup()),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 34,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Color(0xFF16A34A),
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Open now',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Transform.translate(
                offset: const Offset(0, -24),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  decoration: const BoxDecoration(
                    color: _cream,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'The Daily Brew',
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Coffee · Food · Good vibes',
                        style: TextStyle(fontSize: 10.5, color: _stone),
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          PreviewAction(
                            Icons.call_outlined,
                            'Call',
                            Color(0xFFDBEAFE),
                            Color(0xFF2563EB),
                          ),
                          PreviewAction(
                            Icons.chat_bubble_outline_rounded,
                            'WhatsApp',
                            Color(0xFFDCFCE7),
                            Color(0xFF16A34A),
                          ),
                          PreviewAction(
                            Icons.location_on_outlined,
                            'Map',
                            Color(0xFFFEE2E2),
                            Color(0xFFDC2626),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Row(
                        children: [
                          Text(
                            "Today's specials",
                            style: TextStyle(
                              fontFamily: AppTheme.displayFont,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          Text(
                            'See all',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: _brown,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _Dish(
                        Icons.coffee_outlined,
                        'Cappuccino',
                        'Double shot',
                        '₹120',
                        Color(0xFFFEF3C7),
                        Color(0xFF92400E),
                      ),
                      const SizedBox(height: 7),
                      const _Dish(
                        Icons.cake_outlined,
                        'Chocolate cake',
                        'Baked today',
                        '₹150',
                        Color(0xFFFCE7F3),
                        Color(0xFF9D174D),
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1917),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'View full menu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Round-cornered icon button with a label, as on a published page.
class PreviewAction extends StatelessWidget {
  const PreviewAction(
    this.icon,
    this.label,
    this.tint,
    this.color, {
    super.key,
  });

  final IconData icon;
  final String label;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF44403C),
          ),
        ),
      ],
    );
  }
}

class _Dish extends StatelessWidget {
  const _Dish(
    this.icon,
    this.name,
    this.note,
    this.price,
    this.tint,
    this.color,
  );

  final IconData icon;
  final String name;
  final String note;
  final String price;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78350F).withValues(alpha: .14),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  note,
                  style: const TextStyle(
                    fontSize: 9,
                    color: MenuPagePreview._stone,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: MenuPagePreview._brown,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}

/// Steaming cup on a saucer for the café cover.
class _CoffeeCup extends StatelessWidget {
  const _CoffeeCup();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(120, 108), painter: _CupPainter());
}

class _CupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final cream = Paint()..color = const Color(0xFFFFFBEB);
    final steam = Paint()
      ..color = const Color(0xD9FDE68A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [38.0, 50.0, 62.0]) {
      final top = x == 50 ? 3.0 : 8.0;
      canvas.drawPath(
        Path()
          ..moveTo(x, top)
          ..cubicTo(x - 4, top + 6, x + 4, top + 9, x, top + 15),
        steam,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 80), width: 80, height: 14),
      Paint()..color = const Color(0xFFFEF3C7),
    );
    canvas.drawPath(
      Path()
        ..moveTo(78, 38)
        ..arcToPoint(const Offset(78, 58), radius: const Radius.circular(10)),
      Paint()
        ..color = const Color(0xFFFFFBEB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(22, 32)
        ..lineTo(78, 32)
        ..lineTo(78, 48)
        ..arcToPoint(const Offset(22, 48), radius: const Radius.circular(28))
        ..close(),
      cream,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 32), width: 56, height: 12),
      Paint()..color = const Color(0xFF92400E),
    );
    canvas.drawPath(
      Path()
        ..moveTo(41, 32)
        ..quadraticBezierTo(50, 37, 59, 32),
      Paint()
        ..color = const Color(0xFFFDE68A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CupPainter old) => false;
}
