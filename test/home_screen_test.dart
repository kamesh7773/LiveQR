import 'package:base_flutter_application/features/auth/view_models/auth_view_model.dart';
import 'package:base_flutter_application/features/home/models/live_page.dart';
import 'package:base_flutter_application/features/home/view_models/home_view_model.dart';
import 'package:base_flutter_application/features/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> pumpHome(WidgetTester tester, List<LivePage> pages) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authUserProvider.overrideWith((ref) => Stream.value(null)),
        backendProfileProvider.overrideWith((ref) async => <String, dynamic>{}),
        myPagesProvider.overrideWith((ref) => pages),
      ],
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
  // Animations repeat forever, so pump a few frames instead of settling.
  await tester.pump(const Duration(milliseconds: 500));
}

/// Real fonts, so text measures as it does in the app (the default test font is much wider).
Future<void> loadFonts() async {
  for (final (family, files) in [
    ('PlusJakartaSans', ['400', '500', '600', '700', '800']),
    ('BricolageGrotesque', ['600', '700']),
  ]) {
    final loader = FontLoader(family);
    for (final w in files) {
      loader.addFont(rootBundle.load('assets/fonts/$family-$w.ttf'));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(loadFonts);

  testWidgets('owner with pages sees the shelf', (tester) async {
    await pumpHome(tester, const [
      LivePage(
        id: 'a',
        title: 'The Daily Brew',
        type: PageType.menu,
        isLive: true,
        scansThisWeek: 12,
      ),
    ]);
    expect(find.text('scan next?'), findsOneWidget);
    expect(find.text('Your pages'), findsOneWidget);
    expect(find.text('New page'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('new owner sees the first-visit layout', (tester) async {
    await pumpHome(tester, const []);
    expect(find.text('One live page.'), findsOneWidget);
    expect(find.text('Or pick a starting point'), findsOneWidget);
    expect(find.text('EXAMPLE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a page-type shortcut starts the prompt', (tester) async {
    await pumpHome(tester, const []);
    await tester.ensureVisible(find.text('Restaurant menu'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Restaurant menu'));
    await tester.pump();
    expect(find.text('A restaurant menu for '), findsOneWidget);
  });
}
