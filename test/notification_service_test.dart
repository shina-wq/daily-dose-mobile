import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_dose_mobile/core/navigation/app_router.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_dose_model.dart';
import 'package:daily_dose_mobile/services/notification_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class _RecordedScheduleCall {
  _RecordedScheduleCall({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.notificationDetails,
    required this.androidScheduleMode,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final tz.TZDateTime scheduledDate;
  final NotificationDetails notificationDetails;
  final AndroidScheduleMode androidScheduleMode;
  final String? payload;
}

class _RecordedShowCall {
  _RecordedShowCall({
    required this.id,
    required this.title,
    required this.body,
    required this.notificationDetails,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final NotificationDetails notificationDetails;
  final String? payload;
}

class _FakeNotificationClient implements LocalNotificationClient {
  final List<_RecordedScheduleCall> scheduledCalls = [];
  final List<_RecordedShowCall> showCalls = [];
  final List<int> canceledIds = [];

  @override
  Future<void> cancel(int id) async {
    canceledIds.add(id);
  }

  @override
  Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return null;
  }

  @override
  Future<void> initialize({
    required InitializationSettings settings,
    required void Function(NotificationResponse response) onDidReceiveNotificationResponse,
  }) async {
    return;
  }

  @override
  Future<void> show({
    required int id,
    required String? title,
    required String? body,
    required NotificationDetails notificationDetails,
    String? payload,
  }) async {
    showCalls.add(
      _RecordedShowCall(
        id: id,
        title: title,
        body: body,
        notificationDetails: notificationDetails,
        payload: payload,
      ),
    );
  }

  @override
  Future<IOSFlutterLocalNotificationsPlugin?> resolveIosImplementation() async {
    return null;
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required String? title,
    required String? body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? payload,
  }) async {
    scheduledCalls.add(
      _RecordedScheduleCall(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: androidScheduleMode,
        payload: payload,
      ),
    );
  }
}

void main() {
  const testUid = 'test-user-123';
  late FakeFirebaseFirestore firestore;
  late _FakeNotificationClient client;
  late DateTime now;
  late NotificationService service;

  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  });

  setUp(() {
    firestore = FakeFirebaseFirestore();
    client = _FakeNotificationClient();
    now = DateTime(2026, 5, 7, 12, 0);
    service = NotificationService.forTesting(
      client: client,
      firestore: firestore,
      now: () => now,
    );
  });

  test('schedules reminder five minutes before the dose time', () async {
    final dose = MedicationDoseModel(
      id: 'dose-1',
      uid: testUid,
      medicationId: 'med-1',
      medicationName: 'Metformin',
      dosage: '500mg',
      scheduledTime: now.add(const Duration(minutes: 10)),
      status: DoseStatus.pending,
      createdAt: now,
    );

    await service.scheduleMedicationReminder(testUid, dose);

    expect(client.scheduledCalls, hasLength(1));
    expect(client.showCalls, isEmpty);
    expect(client.canceledIds, contains(dose.id.hashCode));
    expect(
      client.scheduledCalls.single.scheduledDate.isAtSameMomentAs(now.add(const Duration(minutes: 5))),
      isTrue,
    );
    expect(client.scheduledCalls.single.payload, '/medications/med-1/dose/dose-1');

    final saved = await firestore
        .collection('users')
        .doc(testUid)
        .collection('medication_notifications')
        .doc('reminder_dose-1')
        .get();

    expect(saved.exists, isTrue);
  });

  test('uses a scheduled local notification so reminders survive app closure', () async {
    final dose = MedicationDoseModel(
      id: 'dose-2',
      uid: testUid,
      medicationId: 'med-2',
      medicationName: 'Lisinopril',
      dosage: '10mg',
      scheduledTime: now.add(const Duration(minutes: 20)),
      status: DoseStatus.pending,
      createdAt: now,
    );

    await service.scheduleMedicationReminder(testUid, dose);

    expect(client.scheduledCalls, hasLength(1));
    expect(client.showCalls, isEmpty);
    expect(client.scheduledCalls.single.androidScheduleMode, AndroidScheduleMode.exact);
  });

  test('routes medication notification taps to the medications screen', () {
    expect(
      NotificationService.resolveNotificationRoute('/medications/med-9/dose/dose-9'),
      AppRouter.medicationsRoute,
    );
  });

  test('schedules multiple pending doses independently', () async {
    final baseTime = now.add(const Duration(minutes: 30));

    await firestore
        .collection('users')
        .doc(testUid)
        .collection('medication_doses')
        .doc('dose-a')
        .set(
          MedicationDoseModel(
            id: 'dose-a',
            uid: testUid,
            medicationId: 'med-a',
            medicationName: 'Aspirin',
            dosage: '100mg',
            scheduledTime: baseTime,
            status: DoseStatus.pending,
            createdAt: now,
          ).toMap(),
        );

    await firestore
        .collection('users')
        .doc(testUid)
        .collection('medication_doses')
        .doc('dose-b')
        .set(
          MedicationDoseModel(
            id: 'dose-b',
            uid: testUid,
            medicationId: 'med-b',
            medicationName: 'Vitamin D',
            dosage: '2000 IU',
            scheduledTime: baseTime.add(const Duration(minutes: 15)),
            status: DoseStatus.pending,
            createdAt: now,
          ).toMap(),
        );

    await service.scheduleAllPendingReminders(testUid);

    expect(client.scheduledCalls, hasLength(2));
    expect(
      client.scheduledCalls.map((call) => call.payload),
      containsAll(<String?>[
        '/medications/med-a/dose/dose-a',
        '/medications/med-b/dose/dose-b',
      ]),
    );
  });

  test('does not create duplicate reminder notifications for the same dose', () async {
    final dose = MedicationDoseModel(
      id: 'dose-dup',
      uid: testUid,
      medicationId: 'med-dup',
      medicationName: 'Atorvastatin',
      dosage: '20mg',
      scheduledTime: now.add(const Duration(minutes: 15)),
      status: DoseStatus.pending,
      createdAt: now,
    );

    await service.scheduleMedicationReminder(testUid, dose);
    await service.scheduleMedicationReminder(testUid, dose);

    expect(client.scheduledCalls, hasLength(1));

    final notifications = await firestore
        .collection('users')
        .doc(testUid)
        .collection('medication_notifications')
        .get();

    expect(notifications.docs, hasLength(1));
    expect(notifications.docs.single.id, 'reminder_dose-dup');
  });
}