import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/history/presentation/controllers/history_state.dart';
import 'package:mobile/features/history/presentation/widgets/history_filter_bar.dart';

void main() {
  for (final largeText in [false, true]) {
    testWidgets(
      'history filter labels stay centered (${largeText ? 'large dark' : 'normal light'})',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (largeText) {
          tester.platformDispatcher.textScaleFactorTestValue = 1.8;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        }
        var selected = HistoryFilter.semua;
        await tester.pumpWidget(
          MaterialApp(
            theme: largeText ? AppTheme.dark() : AppTheme.light(),
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: HistoryFilterBar(
                      selected: selected,
                      onSelected: (filter) => setState(() => selected = filter),
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final scrollable = find.descendant(
          of: find.byType(HistoryFilterBar),
          matching: find.byType(Scrollable),
        );
        for (final filter in HistoryFilter.values) {
          final button = find.widgetWithText(TextButton, filter.label);
          await tester.scrollUntilVisible(button, 100, scrollable: scrollable);
          await tester.pumpAndSettle();
          final pill = tester.getRect(
            find.descendant(of: button, matching: find.byType(Material)).first,
          );
          final label = tester.getRect(find.text(filter.label));
          expect(label.center.dy, closeTo(pill.center.dy, 0.5));
          expect(pill.height, lessThan(48));
          expect(tester.getRect(button).height, greaterThanOrEqualTo(48));
        }
        final button = find.widgetWithText(TextButton, 'Rendah');
        await tester.scrollUntilVisible(button, -100, scrollable: scrollable);
        await tester.pumpAndSettle();
        final pill = tester.getRect(
          find.descendant(of: button, matching: find.byType(Material)).first,
        );
        // The compact visual still accepts taps in its extra touch padding.
        final tap = Offset(pill.center.dx, tester.getRect(button).top + 1);
        expect(tap.dy, lessThan(pill.top));
        await tester.tapAt(tap);
        await tester.pumpAndSettle();
        expect(selected, HistoryFilter.rendah);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
