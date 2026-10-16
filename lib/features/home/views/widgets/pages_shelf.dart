import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/live_page.dart';
import '../../../../core/widgets/phone_preview.dart';

/// Pages standing as phones on a soft perspective grid floor, plus a "New page" outline.
class PagesShelf extends StatelessWidget {
  const PagesShelf({
    super.key,
    required this.pages,
    required this.onOpen,
    required this.onNew,
  });

  final List<LivePage> pages;
  final ValueChanged<LivePage> onOpen;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    final count = pages.length + 1;
    // On wide screens the outer phones turn in toward the middle.
    double turn(int i) =>
        narrow || count < 2 ? 0 : (i == 0 ? 18 : (i == count - 1 ? -18 : 0));
    final slots = [
      for (final (i, page) in pages.indexed)
        _Slot(
          label: page.title,
          status: '${page.isLive ? 'Live' : 'Draft'} · ${_typeName(page.type)}',
          live: page.isLive,
          turn: turn(i),
          onTap: () => onOpen(page),
          child: PhoneFrame(width: 210, screen: previewFor(page)),
        ),
      _Slot(
        label: 'New page',
        status: 'Describe it, we build it',
        turn: turn(count - 1),
        onTap: onNew,
        child: const _GhostPhone(),
      ),
    ];

    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(
          left: -400,
          right: -400,
          bottom: -60,
          height: 380,
          child: IgnorePointer(child: _Floor()),
        ),
        if (narrow)
          SizedBox(
            height: 560,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: slots.length,
              separatorBuilder: (_, _) => const SizedBox(width: 20),
              itemBuilder: (_, i) => slots[i],
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < slots.length; i++) ...[
                if (i > 0) const SizedBox(width: 56),
                slots[i],
              ],
            ],
          ),
      ],
    );
  }
}

/// The right preview for a page type.
Widget previewFor(LivePage page) => switch (page.type) {
  PageType.card => CardPagePreview(name: page.title),
  _ => const MenuPagePreview(),
};

String _typeName(PageType type) => switch (type) {
  PageType.business => 'Business',
  PageType.menu => 'Menu',
  PageType.card => 'Card',
  PageType.event => 'Event',
};

class _Turn extends StatelessWidget {
  const _Turn({required this.degrees, required this.child});

  final double degrees;
  final Widget child;

  @override
  Widget build(BuildContext context) => Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, .0007)
      ..rotateY(degrees * math.pi / 180),
    child: child,
  );
}

class _Slot extends StatefulWidget {
  const _Slot({
    required this.label,
    required this.status,
    required this.onTap,
    required this.child,
    required this.turn,
    this.live,
  });

  final String label;
  final String status;
  final VoidCallback onTap;
  final Widget child;

  /// Degrees the phone (not its label) is turned around the vertical axis.
  final double turn;

  /// null for the "New page" slot (no status dot).
  final bool? live;

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${widget.label}, ${widget.status}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedSlide(
            offset: Offset(0, _hover ? -.02 : 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Turn(degrees: widget.turn, child: widget.child),
                // Soft pedestal glow: a blurred ellipse just under the phone.
                Container(
                  width: 200,
                  height: 14,
                  margin: const EdgeInsets.only(top: 6, bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(
                      Radius.elliptical(100, 7),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: .28),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.label,
                  style: const TextStyle(
                    fontFamily: AppTheme.displayFont,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.live != null) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.live!
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.status,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GhostPhone extends StatelessWidget {
  const _GhostPhone();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(),
      child: Container(
        width: 210,
        height: 210 * 560 / 270,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(36),
        ),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: .6),
                blurRadius: 34,
                offset: const Offset(0, 16),
                spreadRadius: -12,
              ),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.violet.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final outline = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(36)),
      );
    for (final metric in outline.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => false;
}

/// Lavender grid tilted into the distance, fading out at its edges.
class _Floor extends StatelessWidget {
  const _Floor();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 900,
            height: 240,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(450),
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFC4B5FD).withValues(alpha: .5),
                  const Color(0xFFC4B5FD).withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => RadialGradient(
            center: Alignment.topCenter,
            radius: .9,
            colors: const [Colors.black, Colors.transparent],
            stops: const [.25, 1],
          ).createShader(rect),
          child: Transform(
            alignment: Alignment.topCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, .0014)
              ..rotateX(64 * math.pi / 180),
            child: const CustomPaint(painter: _GridPainter()),
          ),
        ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: .16)
      ..strokeWidth = 1;
    const step = 72.0;
    for (var x = size.width / 2 % step; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height * 2), paint);
    }
    for (var y = 0.0; y < size.height * 2; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
