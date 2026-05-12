import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:daily_dose_mobile/app.dart';

void main() {
  testWidgets('app shows the primary navigation shell', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: DailyDoseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Meds'), findsOneWidget);
    expect(find.text('Visits'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
