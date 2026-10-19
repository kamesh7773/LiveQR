import 'package:flutter/painting.dart';

import '../../home/models/live_page.dart';

/// A generated page, as returned by POST /v1/ai/generate.
/// Mirrors `pageSpecSchema` in liveqr-backend/src/ai/page-spec.js; the backend validates it.
class PageSpec {
  const PageSpec({
    required this.type,
    required this.title,
    required this.tagline,
    required this.accent,
    required this.sections,
    required this.actions,
    required this.questions,
    this.images = const [],
  });

  final PageType type;
  final String title;
  final String tagline;
  final Color accent;
  final List<PageSection> sections;
  final List<PageAction> actions;

  /// Facts the AI needs from the owner instead of inventing them.
  final List<String> questions;

  /// URLs of the owner's uploaded photos; the first is the cover.
  final List<String> images;

  static const _accents = {
    'indigo': Color(0xFF4F46E5),
    'violet': Color(0xFF7C3AED),
    'rose': Color(0xFFE11D48),
    'amber': Color(0xFFD97706),
    'emerald': Color(0xFF059669),
    'sky': Color(0xFF0284C7),
  };

  factory PageSpec.fromJson(Map<String, dynamic> json) => PageSpec(
    type: PageType.values.byName(json['type'] as String),
    title: json['title'] as String,
    tagline: json['tagline'] as String,
    accent: _accents[json['accent']] ?? _accents['indigo']!,
    sections: [
      for (final s in json['sections'] as List)
        PageSection(
          heading: s['heading'] as String,
          body: s['body'] as String,
          items: [
            for (final i in s['items'] as List)
              (
                name: i['name'] as String,
                detail: i['detail'] as String,
                price: i['price'] as String,
              ),
          ],
        ),
    ],
    actions: [
      for (final a in json['actions'] as List)
        (
          kind: a['kind'] as String,
          label: a['label'] as String,
          value: a['value'] as String,
        ),
    ],
    questions: List<String>.from(json['questions'] as List),
    images: List<String>.from(json['images'] as List? ?? const []),
  );
}

class PageSection {
  const PageSection({
    required this.heading,
    required this.body,
    required this.items,
  });

  final String heading;
  final String body;
  final List<({String name, String detail, String price})> items;
}

/// kind: call | whatsapp | email | website | map
typedef PageAction = ({String kind, String label, String value});
