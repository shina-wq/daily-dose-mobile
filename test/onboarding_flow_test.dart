import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daily_dose_mobile/core/navigation/app_router.dart';
import 'package:daily_dose_mobile/core/providers/storage_provider.dart';
import 'package:daily_dose_mobile/features/onboarding/models/onboarding_model.dart';
import 'package:daily_dose_mobile/features/onboarding/screens/onboarding_flow_screen.dart';
import 'package:daily_dose_mobile/services/auth_service.dart';
import 'package:daily_dose_mobile/services/firestore_service.dart';
import 'package:daily_dose_mobile/core/utils/token_storage.dart';

class FakeUserStorage extends UserStorage {
  int setOnboardedCallCount = 0;

  @override
  Future<void> setOnboarded(bool value) async {
    setOnboardedCallCount += 1;
  }

  @override
  Future<Map<String, String?>> readBasic() async {
    return const {'uid': null, 'email': null, 'name': null, 'onboarded': null};
  }
}

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
    final mockUser = MockUser(uid: 'user-123', email: 'sarah@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirestore = FakeFirestoreService();

    // Inject test instances
    AuthService.setInstanceForTesting(mockAuth);
    FirestoreService.setInstanceForTesting(mockFirestore);

    final fakeStorage = FakeUserStorage();

    await tester.pumpWidget(
      ProviderScope(overrides: [userStorageProvider.overrideWithValue(fakeStorage)], child: _buildTestApp(home: const OnboardingFlowScreen())),
    );

    // Ensure large surface for consistent layout
    tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    // Advance through steps to completion
    final continueFinder = find.widgetWithText(FilledButton, 'Continue');
    for (var i = 0; i < 3; i++) {
      await tester.tap(continueFinder);
      await tester.pumpAndSettle();
    }

    // Now on last step, tap Complete Setup
    final completeFinder = find.widgetWithText(FilledButton, 'Complete Setup');
    expect(completeFinder, findsOneWidget);
    await tester.tap(completeFinder);
    await tester.pumpAndSettle();

    // Local storage should be updated
    expect(fakeStorage.setOnboardedCallCount, greaterThanOrEqualTo(1));

    // Firestore document should include onboarding data
    final data = mockFirestore.savedUserData('user-123');
    expect(data, isNotNull);
    expect(data?['onboarding'], isA<Map>());
    expect(find.text('Home Screen'), findsOneWidget);
  });

  testWidgets('skip button advances step and does not crash', (tester) async {
    final mockUser = MockUser(uid: 'user-456', email: 'skip@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final mockFirestore = FakeFirestoreService();

    AuthService.setInstanceForTesting(mockAuth);
    FirestoreService.setInstanceForTesting(mockFirestore);

    final fakeStorage = FakeUserStorage();

    await tester.pumpWidget(
      ProviderScope(overrides: [userStorageProvider.overrideWithValue(fakeStorage)], child: _buildTestApp(home: const OnboardingFlowScreen())),
    );

    tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
    tester.binding.window.devicePixelRatioTestValue = 1.0;
    addTearDown(() {
      tester.binding.window.clearPhysicalSizeTestValue();
      tester.binding.window.clearDevicePixelRatioTestValue();
    });

    // Move to step 1 (initially 0), then tap skip
    final continueFinder = find.widgetWithText(FilledButton, 'Continue');
    await tester.tap(continueFinder);
    await tester.pumpAndSettle();

    final skipFinder = find.text('Skip for now');
    expect(skipFinder, findsOneWidget);
    await tester.tap(skipFinder);
    await tester.pumpAndSettle();

    // Should have advanced a step; ensure Continue still present
    expect(continueFinder, findsOneWidget);
  });
}
