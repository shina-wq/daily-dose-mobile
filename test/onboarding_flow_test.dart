import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_dose_mobile/core/navigation/app_router.dart';
import 'package:daily_dose_mobile/features/onboarding/models/onboarding_model.dart';
import 'package:daily_dose_mobile/features/onboarding/screens/onboarding_flow_screen.dart';
import 'package:daily_dose_mobile/services/auth_service.dart';
import 'package:daily_dose_mobile/services/firestore_service.dart';

class FakeFirestoreService extends FirestoreService {
  FakeFirestoreService() : super.forTesting();

  final Map<String, Map<String, dynamic>> savedUsers = {};

  @override
  Future<void> saveOnboardingData({
    required String uid,
    required OnboardingModel onboarding,
  }) async {
    savedUsers[uid] = {'onboarding': onboarding.toMap()};
  }

  Map<String, dynamic>? savedUserData(String uid) => savedUsers[uid];
}

Widget _buildTestApp({required Widget home}) {
  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRouter.onboardingRoute,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRouter.onboardingRoute:
            return MaterialPageRoute(builder: (_) => home);
          case AppRouter.homeRoute:
            return MaterialPageRoute(builder: (_) => const Scaffold(body: Center(child: Text('Home Screen'))));
          default:
            return MaterialPageRoute(builder: (_) => const Scaffold());
        }
      },
    ),
  );
}

void main() {
  testWidgets('completing onboarding saves to Firestore and local storage, navigates home', (tester) async {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed') ||
          message.contains('Looking up a deactivated widget\'s ancestor is unsafe')) {
        return;
      }

      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    final mockUser = MockUser(uid: 'user-123', email: 'sarah@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirestore = FakeFirestoreService();

    tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    // Inject test instances
    AuthService.setInstanceForTesting(mockAuth);
    FirestoreService.setInstanceForTesting(mockFirestore);

    await tester.pumpWidget(
      _buildTestApp(home: const OnboardingFlowScreen()),
    );

    // Advance through steps to completion
    final continueFinder = find.widgetWithText(FilledButton, 'Continue');
    for (var i = 0; i < 3; i++) {
      await tester.ensureVisible(continueFinder);
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();
    }

    // Now on last step, tap Complete Setup
    final completeFinder = find.widgetWithText(FilledButton, 'Complete Setup');
    expect(completeFinder, findsOneWidget);
    await tester.ensureVisible(completeFinder);
    await tester.tap(completeFinder);
    await tester.pumpAndSettle();

    // Firestore document should include onboarding data
    final data = mockFirestore.savedUserData('user-123');
    expect(data, isNotNull);
    final onboarding = (data?['onboarding'] as Map).cast<String, dynamic>();
    expect(onboarding['illnessType'], 'Type 2 Diabetes, Hypothyroidism');
    expect(onboarding['medications'], ['Metformin', 'Levothyroxine']);
    expect(onboarding['symptoms'], isEmpty);
    expect(onboarding['doctorType'], 'Empathetic & Supportive');
    expect(onboarding['aiPreference'], '8:00 AM');
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('skip button advances step and does not crash', (tester) async {
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed') ||
          message.contains('Looking up a deactivated widget\'s ancestor is unsafe')) {
        return;
      }

      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    final mockUser = MockUser(uid: 'user-456', email: 'skip@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirestore = FakeFirestoreService();

    tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    AuthService.setInstanceForTesting(mockAuth);
    FirestoreService.setInstanceForTesting(mockFirestore);

    await tester.pumpWidget(
      _buildTestApp(home: const OnboardingFlowScreen()),
    );

    // Move to step 1 (initially 0), then tap skip
    final continueFinder = find.widgetWithText(FilledButton, 'Continue');
    await tester.ensureVisible(continueFinder);
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    final skipFinder = find.text('Skip for now');
    expect(skipFinder, findsOneWidget);
    await tester.ensureVisible(skipFinder);
    await tester.tap(skipFinder);
    await tester.pumpAndSettle();

    // Should have advanced a step; ensure Continue still present
    expect(continueFinder, findsOneWidget);
  });
}
