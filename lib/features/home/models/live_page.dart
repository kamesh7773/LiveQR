import 'package:flutter/foundation.dart';

enum PageType { business, menu, card, event }

/// An owner's page as shown on Home.
@immutable
class LivePage {
  const LivePage({
    required this.id,
    required this.title,
    required this.type,
    required this.isLive,
    this.scansThisWeek = 0,
  });

  final String id;
  final String title;
  final PageType type;
  final bool isLive;
  final int scansThisWeek;
}
