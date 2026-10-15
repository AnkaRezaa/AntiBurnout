import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/responsive/app_scale.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:mobile/shared/widgets/app_blob_background.dart';

class _Viewport {
  const _Viewport(this.name, this.size, this.padding, [this.keyboard = 0]);

  final String name;
  final Size size;
  final EdgeInsets padding;
  final double keyboard;
}

class _CircleCanvas implements Canvas {
  final circles = <({Offset center, double radius})>[];

  @override
  void drawCircle(Offset center, double radius, Paint paint) {
    circles.add((center: center, radius: radius));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const viewports = [
    _Viewport(
      'portrait phone',
      Size(390, 844),
      EdgeInsets.only(top: 44, bottom: 24),
    ),
    _Viewport(
      'landscape phone',
      Size(844, 390),
      EdgeInsets.only(top: 24, bottom: 16),
    ),
    _Viewport(
      'short body above keyboard',
      Size(390, 844),
      EdgeInsets.only(top: 44, bottom: 24),
      680,
    ),
  ];

  for (final dark in [false, true]) {
    for (final subtle in [false, true]) {
      testWidgets(
        '${dark ? 'dark' : 'light'} ${subtle ? 'subtle' : 'normal'} blobs stay clear of status and navigation bars',
        (tester) async {
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          final theme = dark ? AppTheme.dark() : AppTheme.light();
          var navigationTaps = 0;
          const captureKey = ValueKey('blob-bar-capture');
          const navigationKey = ValueKey('test-navigation-bar');

          for (final viewport in viewports) {
            tester.view.physicalSize = viewport.size;
            await tester.pumpWidget(
              MaterialApp(
                theme: theme,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    padding: viewport.padding,
                    viewPadding: viewport.padding,
                    viewInsets: EdgeInsets.only(bottom: viewport.keyboard),
                  ),
                  child: child!,
                ),
                home: RepaintBoundary(
                  key: captureKey,
                  child: Scaffold(
                    body: AppBlobBackground(
                      refreshKey: viewport.name,
                      subtle: subtle,
                      child: const SizedBox.expand(),
                    ),
                    bottomNavigationBar: SizedBox(
                      key: navigationKey,
                      height: 72,
                      child: Material(
                        color: theme.colorScheme.surface,
                        child: TextButton(
                          onPressed: () => navigationTaps++,
                          child: const Text('Riwayat'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pumpAndSettle();
            final background = find.byType(AppBlobBackground);
            final paintFinder = find.descendant(
              of: background,
              matching: find.byKey(const ValueKey('app-blob-paint')),
            );
            final paintContext = tester.element(paintFinder);
            final safePadding = MediaQuery.paddingOf(paintContext);
            final gap = paintContext.ui(12);
            final bodyRect = tester.getRect(background);
            final paintSize = tester.getSize(paintFinder);
            final top = safePadding.top + gap;
            final bottom = paintSize.height - safePadding.bottom - gap;
            final painter = tester.widget<CustomPaint>(paintFinder).painter!;
            final recorded = _CircleCanvas();
            painter.paint(recorded, paintSize);
            expect(recorded.circles, isNotEmpty, reason: viewport.name);
            // Check every circle, regardless of which random edge or interior
            // position was selected. No particular random layout is required.
            for (final circle in recorded.circles) {
              expect(
                circle.center.dy - circle.radius,
                greaterThanOrEqualTo(top - 0.001),
                reason: '${viewport.name}: the full circle clears the top bar',
              );
              expect(
                circle.center.dy + circle.radius,
                lessThanOrEqualTo(bottom + 0.001),
                reason: '${viewport.name}: the full circle clears the navbar',
              );
            }
            expect(
              bodyRect.bottom,
              lessThanOrEqualTo(
                tester.getTopLeft(find.byKey(navigationKey)).dy,
              ),
            );

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
            final backgroundArgb = theme.scaffoldBackgroundColor.toARGB32();
            final channels = [
              (backgroundArgb >> 16) & 0xff,
              (backgroundArgb >> 8) & 0xff,
              backgroundArgb & 0xff,
            ];
            var decoratedPixels = 0;
            var markedSafeAreaPixels = 0;
            for (
              var y = bodyRect.top.ceil();
              y < bodyRect.bottom.floor();
              y++
            ) {
              for (var x = 0; x < image.width; x++) {
                final offset = (y * image.width + x) * 4;
                final isDecorated =
                    (rgba.getUint8(offset) - channels[0]).abs() > 1 ||
                    (rgba.getUint8(offset + 1) - channels[1]).abs() > 1 ||
                    (rgba.getUint8(offset + 2) - channels[2]).abs() > 1;
                if (!isDecorated) continue;
                decoratedPixels++;
                // Leave a pixel for circle-edge antialiasing at the boundary.
                if (y < (bodyRect.top + top - 1).floor() ||
                    y >= (bodyRect.top + bottom + 1).ceil()) {
                  markedSafeAreaPixels++;
                }
              }
            }
            image.dispose();
            expect(
              markedSafeAreaPixels,
              0,
              reason:
                  '${viewport.name}: the status-bar and navbar gaps stay plain',
            );
            expect(
              decoratedPixels,
              greaterThan(math.min(100, paintSize.height.floor())),
              reason: '${viewport.name}: decoration remains visible inside',
            );
            await tester.tap(find.text('Riwayat'));
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull, reason: viewport.name);
          }
          expect(navigationTaps, viewports.length);
        },
      );
    }
  }

  testWidgets('auth circles clear the system bars even above a keyboard', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final viewport in [
      ...viewports,
      const _Viewport(
        'no vertical drawing space',
        Size(390, 844),
        EdgeInsets.only(top: 44, bottom: 24),
        800,
      ),
    ]) {
      tester.view.physicalSize = viewport.size;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: viewport.padding,
              viewPadding: viewport.padding,
              viewInsets: EdgeInsets.only(bottom: viewport.keyboard),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [AuthBackdrop(), SizedBox.expand()],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final backdrop = find.byType(AuthBackdrop);
      final context = tester.element(backdrop);
      final padding = MediaQuery.paddingOf(context);
      final bounds = tester.getRect(backdrop);
      final gap = context.ui(12);
      final safeTop = bounds.top + padding.top + gap;
      final safeBottom = bounds.bottom - padding.bottom - gap;
      final availableHeight = math.max(0.0, safeBottom - safeTop);
      final circles = find.descendant(
        of: backdrop,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration as BoxDecoration).shape == BoxShape.circle,
        ),
      );
      expect(
        circles,
        findsNWidgets(availableHeight > 0 ? 3 : 0),
        reason: viewport.name,
      );
      for (final circle in circles.evaluate()) {
        final circleBounds = tester.getRect(
          find.byElementPredicate((element) => identical(element, circle)),
        );
        expect(
          circleBounds.top,
          greaterThanOrEqualTo(safeTop - 0.001),
          reason: viewport.name,
        );
        expect(
          circleBounds.bottom,
          lessThanOrEqualTo(safeBottom + 0.001),
          reason: viewport.name,
        );
        expect(circleBounds.width, closeTo(circleBounds.height, 0.001));
        expect(circleBounds.height, lessThanOrEqualTo(availableHeight + 0.001));
      }
      expect(tester.takeException(), isNull, reason: viewport.name);
    }
  });
}
