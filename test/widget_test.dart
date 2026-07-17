import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_pulse/app.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LocalPulseApp()));
    await tester.pump();

    expect(find.text('Local Pulse'), findsOneWidget);
  });
}
