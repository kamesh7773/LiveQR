import 'dart:async';

import 'package:base_flutter_application/core/services/api_client.dart';
import 'package:base_flutter_application/features/pages/models/generated_page.dart';
import 'package:base_flutter_application/features/pages/repositories/pages_repository.dart';
import 'package:base_flutter_application/features/pages/view_models/page_draft_view_model.dart';
import 'package:base_flutter_application/features/pages/views/page_draft_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'home_screen_test.dart' show loadFonts;

const _json = {
  'id': 'abc',
  'title': 'Kalyan Jewellers',
  'previewUrl': 'http://localhost:3000/preview/abc',
};

final _request = PageRequest('Kalyan Jewellers card');

/// Publishes without a network: returns the public link the backend would.
class _FakePages extends PagesRepository {
  _FakePages(super.ref);

  final published = <String>[];
  final generated = <PageRequest>[];

  @override
  Future<GeneratedPage> generate(PageRequest request) async {
    generated.add(request);
    return GeneratedPage.fromJson(_json);
  }

  @override
  Future<String> publish(String pageId) async {
    published.add(pageId);
    return 'http://localhost:3000/p/kalyan-jewellers';
  }
}

Future<void> _pumpDraft(
  WidgetTester tester,
  Size size,
  Future<GeneratedPage> Function() result, {
  _FakePages? Function(Ref ref)? pages,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pageDraftProvider(_request).overrideWith((ref) => result()),
        apiClientProvider.overrideWithValue(Dio()),
        if (pages != null)
          pagesRepositoryProvider.overrideWith((ref) => pages(ref)!),
      ],
      child: ToastificationWrapper(
        child: MaterialApp(home: PageDraftScreen(request: _request)),
      ),
    ),
  );
  // Animations repeat forever, so pump past the switcher instead of settling.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

void main() {
  setUpAll(loadFonts);

  test('fromJson reads every field', () {
    final page = GeneratedPage.fromJson(_json);
    expect(page.id, 'abc');
    expect(page.previewUrl, endsWith('/preview/abc'));
  });

  testWidgets('shows progress while the page is being written', (tester) async {
    await _pumpDraft(
      tester,
      const Size(1440, 900),
      () => Completer<GeneratedPage>().future,
    );
    expect(find.text('GENERATING'), findsOneWidget);
    expect(find.textContaining('usually takes 1–3 minutes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(1440, 900), Size(390, 844)]) {
    testWidgets('shows the finished page and its frames at $size', (
      tester,
    ) async {
      await _pumpDraft(tester, size, () async => GeneratedPage.fromJson(_json));
      expect(find.text('DRAFT · NOT PUBLISHED'), findsOneWidget);
      expect(find.text('Kalyan Jewellers'), findsOneWidget);
      expect(find.textContaining('Add these'), findsNothing);
      expect(find.text('Open full page'), findsOneWidget);

      await tester.tap(find.text('Desktop'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Publish shows the live QR code and permanent link', (
    tester,
  ) async {
    late _FakePages fake;
    await _pumpDraft(
      tester,
      const Size(1440, 900),
      () async => GeneratedPage.fromJson(_json),
      pages: (ref) => fake = _FakePages(ref),
    );
    expect(find.text('Your QR code'), findsNothing);

    await tester.tap(find.text('Publish'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(fake.published, ['abc']);
    expect(find.text('LIVE'), findsOneWidget);
    expect(find.text('Your QR code'), findsOneWidget);
    expect(
      find.text('http://localhost:3000/p/kalyan-jewellers'),
      findsOneWidget,
    );
    expect(find.text('Publish'), findsNothing);
    expect(tester.takeException(), isNull);
    // Let the success toast close itself.
    await tester.pump(const Duration(seconds: 6));
  });

  testWidgets('editing the prompt rebuilds the same page from the new text', (
    tester,
  ) async {
    late _FakePages fake;
    await _pumpDraft(
      tester,
      const Size(1440, 900),
      () async => GeneratedPage.fromJson(_json),
      pages: (ref) => fake = _FakePages(ref),
    );

    await tester.tap(find.text('Edit prompt'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text('Kalyan Jewellers card'),
      findsOneWidget,
    ); // current prompt, editable

    await tester.enterText(
      find.byType(TextField),
      'Kalyan Jewellers card. Call +91 98765 43210.',
    );
    await tester.pump();
    await tester.tap(find.text('Rebuild page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    final request = fake.generated.single;
    expect(request.pageId, 'abc');
    expect(request.description, 'Kalyan Jewellers card. Call +91 98765 43210.');
  });
}
