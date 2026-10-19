import 'dart:ui' as ui;

import 'package:base_flutter_application/core/widgets/living_qr.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';

void main() {
  const data = 'https://liveqr.example/p/daily-brew';

  test('rounded QR path keeps the code scannable', () {
    final image = QrImage(
      QrCode(
        payload: QrPayload.fromString(data),
        errorCorrectLevel: QrErrorCorrectLevel.high,
      ),
    );
    final shape = qrModulePath(data);
    final n = image.moduleCount;
    expect(shape.units, n + 2);

    // Module (x, y) is drawn at (x + 1, y + 1) because of the one-module margin.
    bool painted(double x, double y) =>
        shape.path.contains(Offset(x + 1.5, y + 1.5));
    bool inFinder(int x, int y) =>
        (x < 7 && y < 7) || (x >= n - 7 && y < 7) || (x < 7 && y >= n - 7);

    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (inFinder(x, y)) continue;
        expect(
          painted(x.toDouble(), y.toDouble()),
          image.isDark(y, x),
          reason: 'module ($x, $y)',
        );
      }
    }

    // Finders (corners are rounded on purpose): dark ring, light gap, dark 3×3 centre.
    for (final (fx, fy) in [(0, 0), (n - 7, 0), (0, n - 7)]) {
      expect(
        painted(fx + 3.0, fy + 0.0),
        isTrue,
        reason: 'finder ring at ($fx, $fy)',
      );
      expect(
        painted(fx + 3.0, fy + 1.0),
        isFalse,
        reason: 'finder gap at ($fx, $fy)',
      );
      expect(
        painted(fx + 3.0, fy + 3.0),
        isTrue,
        reason: 'finder centre at ($fx, $fy)',
      );
    }
  });

  testWidgets('QR download is a PNG with a white quiet zone and dark finders', (
    tester,
  ) async {
    await tester.runAsync(() async {
      final png = await qrPng(data, size: 512);
      expect(png.sublist(1, 4), 'PNG'.codeUnits);

      final image = await decodeImageFromList(png);
      final n = qrModulePath(data).units - 2;
      // Whole pixels per module; n modules plus 4 quiet modules on each side.
      final module = 512 ~/ (n + 8);
      expect([image.width, image.height], [module * (n + 8), module * (n + 8)]);
      final rgba = (await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;
      int red(double x, double y) =>
          rgba.getUint8((y.round() * image.width + x.round()) * 4);

      expect(red(module * 2, module * 2), 255, reason: 'quiet zone is white');
      expect(
        red(module * 7.5, module * 7.5),
        lessThan(80),
        reason: 'finder centre is dark',
      );
    });
  });
}
