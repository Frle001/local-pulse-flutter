import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:local_pulse/app.dart';
import 'package:local_pulse/features/auth/providers/auth_provider.dart';

void main() {
  testWidgets('App boots to splash screen while auth state is loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateChangesProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: const LocalPulseApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Local Pulse'), findsOneWidget);
  });
}
