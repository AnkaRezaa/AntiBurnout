import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets('menampilkan halaman pembuka', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AntiBurnoutApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('AntiBurnout'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
  });
}
