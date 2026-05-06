import 'package:daily_dose_mobile/core/providers/storage_provider.dart';
import 'package:daily_dose_mobile/features/profile/models/profile_model.dart';
import 'package:daily_dose_mobile/features/profile/screens/profile_screen.dart';
import 'package:daily_dose_mobile/services/api_service.dart';
import 'package:daily_dose_mobile/services/auth_service.dart';
import 'package:daily_dose_mobile/services/firestore_service.dart';
import 'package:daily_dose_mobile/services/profile_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class RecordingFirestoreService extends FirestoreService {
  RecordingFirestoreService() : super.forTesting();

  ProfileModel? lastUpdatedProfile;

  @override
  Future<void> updateProfile(ProfileModel profile) async {
    lastUpdatedProfile = profile;
  }
}

class RecordingApiService extends ApiService {
  RecordingApiService(this.profilePayload);

  final Map<String, dynamic> profilePayload;

  @override
  Future<Map<String, dynamic>?> fetchCurrentUserProfile(String uid) async {
    return profilePayload;
  }
}

Future<void> _setLargeTestSurface(WidgetTester tester) async {
  tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(() {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });
}

void main() {
  test('profile updates are normalized before saving', () async {
    final mockUser = MockUser(uid: 'user-123', email: 'ada@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final firestore = RecordingFirestoreService();

    AuthService.setInstanceForTesting(mockAuth);
    FirestoreService.setInstanceForTesting(firestore);

    final profile = ProfileModel(
      uid: 'ignored',
      name: 'Ada Lovelace',
      email: '',
      age: 45,
      gender: 'Female',
      conditionSummary: 'Type 2 Diabetes',
      careTeamSummary: 'Endocrinology team',
      healthLogsSummary: 'Tracked fatigue and headaches',
    );

    await ProfileService.instance.updateCurrentUserProfile(profile);

    final saved = firestore.lastUpdatedProfile;
    expect(saved, isNotNull);
    expect(saved!.uid, 'user-123');
    expect(saved.email, 'ada@example.com');
    expect(saved.name, 'Ada Lovelace');
    expect(saved.age, 45);
    expect(saved.gender, 'Female');
    expect(saved.conditionSummary, 'Type 2 Diabetes');
    expect(saved.careTeamSummary, 'Endocrinology team');
    expect(saved.healthLogsSummary, 'Tracked fatigue and headaches');
  });

  testWidgets('profile screen loads fetched user data on app start', (tester) async {
    await _setLargeTestSurface(tester);

    final mockUser = MockUser(uid: 'user-321', email: 'grace@example.com');
    final mockAuth = MockFirebaseAuth(signedIn: true, mockUser: mockUser);
    final api = RecordingApiService({
      'uid': 'user-321',
      'name': 'Grace Hopper',
      'email': 'grace@example.com',
      'age': 61,
      'gender': 'Female',
      'profile': {
        'conditionSummary': 'Hypertension, asthma',
        'careTeamSummary': 'Primary care and cardiology',
        'healthLogsSummary': 'Blood pressure logs are stable',
        'avatarUrl': null,
        'updatedAt': '2026-05-06T00:00:00.000Z',
      },
      'onboarding': {
        'illnessType': 'Hypertension, Asthma',
        'medications': ['Amlodipine'],
        'symptoms': ['Fatigue'],
        'doctorType': 'Empathetic & Supportive',
        'aiPreference': '8:00 AM',
      },
    });

    AuthService.setInstanceForTesting(mockAuth);
    ApiService.setInstanceForTesting(api);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Grace Hopper'), findsWidgets);
    expect(find.text('Hypertension, asthma'), findsWidgets);
    expect(find.text('Age 61, Female'), findsOneWidget);

    await tester.tap(find.text('Personal Details'));
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields[0].controller?.text, 'Grace Hopper');
    expect(fields[1].controller?.text, '61');
  });
}