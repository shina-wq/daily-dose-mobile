import 'package:flutter_test/flutter_test.dart';

import 'package:daily_dose_mobile/app.dart';

void main() {
  testWidgets('app shows the primary navigation shell', (tester) async {
    await tester.pumpWidget(const DailyDoseApp());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Meds'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(find.text('Health Log'), findsOneWidget);
    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
