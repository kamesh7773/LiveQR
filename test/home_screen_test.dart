import 'package:base_flutter_application/core/services/navigation_service.dart';
import 'package:base_flutter_application/features/auth/view_models/auth_view_model.dart';
import 'package:base_flutter_application/features/home/view_models/home_view_model.dart';
import 'package:base_flutter_application/features/home/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:toastification/toastification.dart';

Future<void> pumpHome(WidgetTester tester, {bool guide = false}) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authUserProvider.overrideWith((ref) => Stream.value(null)),
        backendProfileProvider.overrideWith((ref) async => <String, dynamic>{}),
      ],
      // Same wiring as the app: dialogs find the navigator through NavigationService.
      child: ToastificationWrapper(
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            navigatorKey: ref
                .read(navigationServiceProvider.notifier)
                .navigatorKey,
            home: HomeScreen(guideOnOpen: guide),
          ),
        ),
      ),
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

  testWidgets(
    'home shows the example scene and starting points, no sample pages',
    (tester) async {
      await pumpHome(tester);
      expect(find.text('One live page.'), findsOneWidget);
      expect(find.text('Or pick a starting point'), findsOneWidget);
      expect(find.text('EXAMPLE'), findsOneWidget);
      expect(find.text('Your pages'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a page-type shortcut starts the prompt', (tester) async {
    await pumpHome(tester);
    await tester.ensureVisible(find.text('Restaurant menu'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.tap(find.text('Restaurant menu'));
    await tester.pump();
    expect(find.text('A restaurant menu for '), findsOneWidget);
  });

  testWidgets('Link adds a checked web address as a chip', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.text('Link'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.byType(TextField).last, 'not a link');
    await tester.tap(find.text('Add'));
    await tester.pump();
    expect(find.textContaining('Enter a web address'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).last,
      'www.instagram.com/cafe',
    );
    await tester.tap(find.text('Add'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('instagram.com'), findsOneWidget);
    expect(find.byType(InputChip), findsOneWidget);
  });

  testWidgets(
    'a guest pressing Create is asked to sign in, keeping the prompt',
    (tester) async {
      await pumpHome(tester);
      expect(
        find.text('Sign in'),
        findsOneWidget,
      ); // navbar, instead of the avatar
      expect(find.text('Welcome to Live QR'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'A bakery in Pune');
      await tester.tap(find.text('Create'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sign in to create your page'), findsOneWidget);

      await tester.tap(find.text('Not now'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Sign in to create your page'), findsNothing);
      expect(find.text('A bakery in Pune'), findsOneWidget);
    },
  );

  testWidgets(
    'guided questions open with the site; Skip puts the answers in the prompt',
    (tester) async {
      await pumpHome(tester, guide: true);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('What would you like to create?'), findsOneWidget);

      await tester.tap(
        find.text('Business page').last,
      ); // the dialog's card, above Home's tile
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('What type of business do you run?'), findsOneWidget);

      await tester.tap(find.text('Jewellery'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(
        find.byType(TextFormField).first,
        'Kalyan Jewellers',
      );
      await tester.pump();
      await tester.tap(find.text('Skip'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('What would you like to create?'), findsNothing);
      expect(
        find.text(
          'Page type: Business page\nType of business: Jewellery\nBusiness name: Kalyan Jewellers',
        ),
        findsOneWidget,
      );
    },
  );
}
