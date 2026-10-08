import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:disasters/main.dart';
import 'package:disasters/providers/user_provider.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: const MunnarivuApp(),
      ),
    );

    // Verify that the title on the onboarding screen is present
    expect(find.text('Setup Profile'), findsOneWidget);
  });
}
