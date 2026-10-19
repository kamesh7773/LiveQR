import 'package:base_flutter_application/features/pages/models/page_spec.dart';
import 'package:base_flutter_application/features/pages/view_models/page_draft_view_model.dart';
import 'package:base_flutter_application/features/pages/views/page_draft_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_screen_test.dart' show loadFonts;

// A real response from the backend (claude CLI, sonnet).
const _json = {
  'type': 'menu',
  'title': 'The Daily Brew',
  'tagline': 'A cosy coffee shop in Koregaon Park, Pune.',
  'accent': 'amber',
  'sections': [
    {
      'heading': 'Menu',
      'body': 'Coffee and a bite, made to slow your day down.',
      'items': [
        {'name': 'Cappuccino', 'detail': '', 'price': '180'},
        {'name': 'Cold Brew', 'detail': '', 'price': '220'},
        {'name': 'Almond Croissant', 'detail': '', 'price': '150'},
      ],
    },
  ],
  'actions': [
    {'kind': 'call', 'label': 'Call us', 'value': '+91 98765 43210'},
  ],
  'questions': [
    "What is the shop's full street address?",
    'What are your opening hours?',
  ],
};

final _request = PageRequest('cafe');

Future<void> pumpDraft(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pageDraftProvider(
          _request,
        ).overrideWith((ref) async => PageSpec.fromJson(_json)),
      ],
      child: MaterialApp(home: PageDraftScreen(request: _request)),
    ),
  );
  // Animations repeat forever, so pump past the switcher instead of settling.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  setUpAll(loadFonts);

  test('fromJson reads every field', () {
    final spec = PageSpec.fromJson(_json);
    expect(spec.sections.single.items[1].price, '220');
    expect(spec.actions.single.kind, 'call');
    expect(spec.questions, hasLength(2));
    expect(spec.images, isEmpty);
    expect(
      PageSpec.fromJson({
        ..._json,
        'images': ['http://x/a.webp'],
      }).images,
      ['http://x/a.webp'],
    );
  });

  for (final size in const [Size(1440, 900), Size(390, 844)]) {
    testWidgets('shows the generated page and questions at $size', (
      tester,
    ) async {
      await pumpDraft(tester, size);
      expect(find.text('DRAFT · NOT PUBLISHED'), findsOneWidget);
      expect(find.text('Almond Croissant'), findsOneWidget);
      expect(find.text('What are your opening hours?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
