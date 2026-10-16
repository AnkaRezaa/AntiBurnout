import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app/navigation/app_bottom_navigation_bar.dart';
import 'package:mobile/core/theme/app_theme.dart';

const _labels = ['Beranda', 'Survei', 'Riwayat', 'Profil'];
const _icons = [
  Icons.home_outlined,
  Icons.assignment_outlined,
  Icons.pending_actions_outlined,
  Icons.person_outline_rounded,
];

class _NavigationHarness extends StatefulWidget {
  const _NavigationHarness({this.onTap});

  final ValueChanged<int>? onTap;

  @override
  State<_NavigationHarness> createState() => _NavigationHarnessState();
}

class _NavigationHarnessState extends State<_NavigationHarness> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SizedBox.expand(),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: selected,
        onTap: (index) {
          setState(() => selected = index);
          widget.onTap?.call(index);
        },
      ),
    );
  }
}

Future<void> _showNavigation(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  EdgeInsets insets = EdgeInsets.zero,
  double textScale = 1,
  bool dark = false,
  ValueChanged<int>? onTap,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          padding: insets,
          viewPadding: insets,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: _NavigationHarness(onTap: onTap),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _bar => find.byType(AppBottomNavigationBar);

Finder get _tapTargets => find.descendant(
  of: find.byType(BottomNavigationBar),
  matching: find.byType(InkResponse),
);

void _expectSafeContent(WidgetTester tester, Size size, EdgeInsets insets) {
  expect(tester.takeException(), isNull);
  final bar = tester.getRect(_bar);
  expect(bar.bottom, closeTo(size.height, 0.1));
  expect(_tapTargets, findsNWidgets(4));
  for (var index = 0; index < _labels.length; index++) {
    final icon = tester.getRect(find.byIcon(_icons[index]));
    final label = tester.getRect(find.text(_labels[index]));
    for (final content in [icon, label]) {
      expect(content.left, greaterThanOrEqualTo(insets.left - 0.1));
      expect(content.right, lessThanOrEqualTo(size.width - insets.right + 0.1));
      expect(content.top, greaterThanOrEqualTo(bar.top - 0.1));
      expect(
        content.bottom,
        lessThanOrEqualTo(size.height - insets.bottom + 0.1),
      );
    }
    final target = tester.getSize(_tapTargets.at(index));
    expect(target.width, greaterThanOrEqualTo(48));
    expect(target.height, greaterThanOrEqualTo(48));
  }
}

void main() {
  testWidgets('navigation icons and height grow and shrink on live resize', (
    tester,
  ) async {
    await _showNavigation(tester, size: const Size(390, 1366));
    final state = tester.state<_NavigationHarnessState>(
      find.byType(_NavigationHarness),
    );
    final phoneIcon = tester.getSize(find.byIcon(Icons.home_outlined));
    final phoneHeight = tester.getSize(_bar).height;
    expect(phoneIcon.width, closeTo(24, 0.1));
    expect(phoneHeight, greaterThanOrEqualTo(56));

    tester.view.physicalSize = const Size(768, 1366);
    await tester.pumpAndSettle();
    final tabletIcon = tester.getSize(find.byIcon(Icons.home_outlined));
    final tabletHeight = tester.getSize(_bar).height;
    expect(tabletIcon.width, greaterThan(phoneIcon.width));
    expect(tabletHeight, greaterThan(phoneHeight));

    tester.view.physicalSize = const Size(1024, 1366);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byIcon(Icons.home_outlined)).width,
      greaterThan(tabletIcon.width),
    );
    expect(tester.getSize(_bar).height, greaterThan(tabletHeight));

    tester.view.physicalSize = const Size(390, 1366);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byIcon(Icons.home_outlined)), phoneIcon);
    expect(tester.getSize(_bar).height, closeTo(phoneHeight, 0.1));
    expect(
      tester.state<_NavigationHarnessState>(find.byType(_NavigationHarness)),
      same(state),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('all navigation tabs remain accessible and tappable', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      final selected = <int>[];
      await _showNavigation(tester, onTap: selected.add);
      for (var index = 0; index < _labels.length; index++) {
        expect(find.bySemanticsLabel(RegExp(_labels[index])), findsWidgets);
        final target = tester.getRect(_tapTargets.at(index));
        expect(target.size.width, greaterThanOrEqualTo(48));
        expect(target.size.height, greaterThanOrEqualTo(48));
        await tester.tapAt(target.center);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<BottomNavigationBar>(find.byType(BottomNavigationBar))
              .currentIndex,
          index,
        );
      }
      expect(selected, [0, 1, 2, 3]);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });

  for (final dark in [false, true]) {
    for (final scenario in [
      (
        name: 'small phone and large text',
        size: const Size(320, 640),
        insets: const EdgeInsets.only(top: 24, bottom: 34),
        textScale: 2.0,
      ),
      (
        name: 'landscape with side cutouts',
        size: const Size(844, 390),
        insets: const EdgeInsets.only(left: 44, right: 44, bottom: 34),
        textScale: 2.0,
      ),
      (
        name: 'tablet with large text',
        size: const Size(1024, 1366),
        insets: const EdgeInsets.only(top: 24, bottom: 34),
        textScale: 2.0,
      ),
    ]) {
      testWidgets(
        'navigation fits ${scenario.name} in ${dark ? 'dark' : 'light'} theme',
        (tester) async {
          await _showNavigation(
            tester,
            size: scenario.size,
            insets: scenario.insets,
            textScale: scenario.textScale,
            dark: dark,
          );
          _expectSafeContent(tester, scenario.size, scenario.insets);
          if (scenario.size.height < 600) {
            expect(
              tester.getSize(find.byIcon(Icons.home_outlined)).width,
              closeTo(24, 0.1),
            );
          }
        },
      );
    }
  }
}
