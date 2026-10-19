import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/phone_preview.dart';
import '../../../home/models/live_page.dart';
import '../../models/page_spec.dart';

const _ink = Color(0xFF1C1917);
const _stone = Color(0xFF78716C);

/// Draws a generated [PageSpec] as the phone screen (250 × 540, see [PhoneFrame]).
/// Scrolls inside the phone when the page is longer than the screen.
class SpecPagePreview extends StatelessWidget {
  const SpecPagePreview({super.key, required this.spec});

  final PageSpec spec;

  static const _typeIcons = {
    PageType.business: Icons.storefront_rounded,
    PageType.menu: Icons.restaurant_menu_rounded,
    PageType.card: Icons.badge_rounded,
    PageType.event: Icons.celebration_rounded,
  };

  static const _actionIcons = {
    'call': Icons.call_outlined,
    'whatsapp': Icons.chat_bubble_outline_rounded,
    'email': Icons.mail_outline_rounded,
    'website': Icons.language_rounded,
    'map': Icons.location_on_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final accent = spec.accent;
    final deep = Color.lerp(accent, Colors.black, .55)!;
    final tint = Color.lerp(accent, Colors.white, .86)!;

    return DefaultTextStyle(
      style: const TextStyle(fontFamily: AppTheme.bodyFont, color: _ink),
      child: ColoredBox(
        color: const Color(0xFFFFFCF8),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 160,
                width: double.infinity,
                child: spec.images.isEmpty
                    ? DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [accent, deep],
                          ),
                        ),
                        child: Align(
                          alignment: const Alignment(0, .15),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .18),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: .5),
                              ),
                            ),
                            child: Icon(
                              _typeIcons[spec.type],
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    : _Photo(url: spec.images.first, fallback: deep),
              ),
              Transform.translate(
                offset: const Offset(0, -22),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFCF8),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        spec.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -.6,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spec.tagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10.5,
                          height: 1.4,
                          color: _stone,
                        ),
                      ),
                      if (spec.actions.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final a in spec.actions)
                              Expanded(
                                child: PreviewAction(
                                  _actionIcons[a.kind] ?? Icons.link_rounded,
                                  a.label,
                                  tint,
                                  accent,
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (spec.images.length > 1) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 84,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: spec.images.length - 1,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 7),
                            itemBuilder: (_, i) => ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                width: 84,
                                child: _Photo(
                                  url: spec.images[i + 1],
                                  fallback: tint,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      for (final section in spec.sections) ...[
                        const SizedBox(height: 16),
                        Text(
                          section.heading,
                          style: const TextStyle(
                            fontFamily: AppTheme.displayFont,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (section.body.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            section.body,
                            style: const TextStyle(
                              fontSize: 10,
                              height: 1.45,
                              color: Color(0xFF44403C),
                            ),
                          ),
                        ],
                        for (final item in section.items) ...[
                          const SizedBox(height: 7),
                          _Item(item: item, accent: accent),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An uploaded photo, cropped to fill; a flat colour while it loads or if it fails.
class _Photo extends StatelessWidget {
  const _Photo({required this.url, required this.fallback});

  final String url;
  final Color fallback;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      frameBuilder: (_, child, frame, sync) =>
          frame == null && !sync ? ColoredBox(color: fallback) : child,
      errorBuilder: (_, _, _) => ColoredBox(color: fallback),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.accent});

  final ({String name, String detail, String price}) item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: .16),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item.detail.isNotEmpty)
                  Text(
                    item.detail,
                    style: const TextStyle(fontSize: 9, color: _stone),
                  ),
              ],
            ),
          ),
          if (item.price.isNotEmpty)
            Text(
              item.price,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
            ),
        ],
      ),
    );
  }
}

/// Placeholder screen while the page is being generated: pulsing grey blocks.
class SpecPageSkeleton extends StatelessWidget {
  const SpecPageSkeleton({super.key, required this.pulse});

  /// 0–1, drives the blocks' brightness.
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width, double radius = 10}) =>
        AnimatedBuilder(
          animation: pulse,
          builder: (context, _) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFFECE9F6),
                const Color(0xFFDCD7EE),
                pulse.value,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );

    return ColoredBox(
      color: const Color(0xFFFFFCF8),
      child: Column(
        children: [
          block(160, width: double.infinity, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                block(20, width: 150),
                const SizedBox(height: 8),
                block(10, width: 190),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < 3; i++)
                      block(42, width: 42, radius: 14),
                  ],
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < 3; i++) ...[
                  block(46, width: double.infinity, radius: 12),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
