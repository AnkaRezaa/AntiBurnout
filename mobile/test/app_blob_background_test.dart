import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/shared/widgets/app_blob_background.dart';

CustomPainter _painter(WidgetTester tester, Finder background) => tester
    .widget<CustomPaint>(
      find.descendant(
        of: background,
        matching: find.byKey(const ValueKey('app-blob-paint')),
      ),
    )
    .painter!;

void main() {
  for (final dark in [false, true]) {
    for (final subtle in [false, true]) {
      testWidgets(
        '${dark ? 'dark' : 'light'} ${subtle ? 'subtle' : 'normal'} decoration includes a blob inside the page',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = const Size(390, 844);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final theme = dark ? AppTheme.dark() : AppTheme.light();
          const captureKey = ValueKey('blob-interior-capture');
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: RepaintBoundary(
                key: captureKey,
                child: Scaffold(
                  body: AppBlobBackground(
                    subtle: subtle,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(captureKey),
          );
          final rendered = await tester.runAsync(
            () => boundary.toImage(pixelRatio: 1),
          );
          expect(rendered, isNotNull);
          final image = rendered!;
          final pixels = await tester.runAsync(
            () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
          );
          expect(pixels, isNotNull);
          final rgba = pixels!;
          final background = theme.scaffoldBackgroundColor.toARGB32();
          final channels = [
            (background >> 16) & 0xff,
            (background >> 8) & 0xff,
            background & 0xff,
          ];
          var paintedPixels = 0;
          // Edge circles alone cannot reach this central region on this
          // viewport. Inspect rendered pixels rather than private blob data.
          for (
            var y = (image.height * 0.25).ceil();
            y < (image.height * 0.75).floor();
            y++
          ) {
            for (
              var x = (image.width * 0.3).ceil();
              x < (image.width * 0.7).floor();
              x++
            ) {
              final offset = (y * image.width + x) * 4;
              if ((rgba.getUint8(offset) - channels[0]).abs() > 1 ||
                  (rgba.getUint8(offset + 1) - channels[1]).abs() > 1 ||
                  (rgba.getUint8(offset + 2) - channels[2]).abs() > 1) {
                paintedPixels++;
              }
            }
          }
          image.dispose();
          expect(
            paintedPixels,
            greaterThan(100),
            reason:
                'At least one visible blob should occupy the page interior.',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'decoration leaves content interactive and stable through ordinary rebuilds',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final semantics = tester.ensureSemantics();
      try {
        final name = TextEditingController();
        addTearDown(name.dispose);
        late StateSetter update;
        var dark = false;
        var taps = 0;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MaterialApp(
                theme: dark ? AppTheme.dark() : AppTheme.light(),
                home: Scaffold(
                  body: AppBlobBackground(
                    child: Column(
                      children: [
                        const Text('Halaman'),
                        TextField(controller: name),
                        ElevatedButton(
                          onPressed: () => taps++,
                          child: const Text('Aksi utama'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        final background = find.byType(AppBlobBackground);
        final original = _painter(tester, background);
        await tester.enterText(find.byType(TextField), 'Nama tetap tersimpan');
        await tester.tap(find.text('Aksi utama'));
        update(() {});
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(_painter(tester, background).shouldRepaint(original), isFalse);
        expect(find.bySemanticsLabel('Aksi utama'), findsOneWidget);
        update(() => dark = true);
        await tester.pumpAndSettle();
        tester.view.physicalSize = const Size(1024, 1366);
        await tester.pumpAndSettle();
        expect(name.text, 'Nama tetap tersimpan');
        expect(
          Theme.of(tester.element(background)).brightness,
          Brightness.dark,
        );
        expect(
          tester.getSize(background),
          tester.getSize(find.byType(Scaffold)),
        );
        await tester.tap(find.text('Aksi utama'));
        expect(taps, 2);
        expect(tester.takeException(), isNull);
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'refresh and returning to a tab change decoration without resetting its content',
    (tester) async {
      final name = TextEditingController();
      final scroll = ScrollController();
      addTearDown(name.dispose);
      addTearDown(scroll.dispose);
      late StateSetter update;
      var active = true;
      var revision = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                update = setState;
                return TickerMode(
                  enabled: active,
                  child: AppBlobBackground(
                    refreshKey: revision,
                    child: ListView(
                      controller: scroll,
                      children: [
                        TextField(controller: name),
                        for (var index = 0; index < 30; index++)
                          SizedBox(height: 72, child: Text('Item $index')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Draf pengguna');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      scroll.jumpTo(180);
      await tester.pumpAndSettle();
      expect(scroll.offset, 180);
      final background = find.byType(AppBlobBackground);
      final initial = _painter(tester, background);
      update(() => revision++);
      await tester.pumpAndSettle();
      final refreshed = _painter(tester, background);
      expect(refreshed.shouldRepaint(initial), isTrue);
      expect(name.text, 'Draf pengguna');
      expect(scroll.offset, 180);
      update(() => active = false);
      await tester.pumpAndSettle();
      update(() => active = true);
      await tester.pumpAndSettle();
      expect(_painter(tester, background).shouldRepaint(refreshed), isTrue);
      expect(name.text, 'Draf pengguna');
      expect(scroll.offset, 180);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('returning from another route renews only the decoration', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final name = TextEditingController();
    addTearDown(name.dispose);
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigator,
        theme: AppTheme.light(),
        home: Scaffold(
          body: AppBlobBackground(
            key: const ValueKey('home-background'),
            child: TextField(controller: name),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Draf halaman asal');
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    final home = find.byKey(const ValueKey('home-background'));
    final original = _painter(tester, home);
    navigator.currentState!.push<void>(
      MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: AppBlobBackground(child: Text('Halaman kedua')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Halaman kedua'), findsOneWidget);
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(_painter(tester, home).shouldRepaint(original), isTrue);
    expect(name.text, 'Draf halaman asal');
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
