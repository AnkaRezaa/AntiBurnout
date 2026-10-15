import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets('menampilkan halaman pembuka', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AntiBurnoutApp()));
    // Asset decoding needs the real event loop before settling animations.
    await tester.runAsync(() async {
      final context = tester.element(find.byType(AntiBurnoutApp));
      await Future.wait([
        for (final asset in [
          'assets/images/LogoAntiBurnout.png',
          'assets/images/girl.png',
          'assets/images/left_leaf.png',
          'assets/images/right_leaf.png',
        ])
          precacheImage(AssetImage(asset), context),
      ]);
    });
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Logo AntiBurnout'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
