import 'package:flutter_test/flutter_test.dart';
import 'package:daily_dose_mobile/features/appointments/models/appointment_model.dart';
import 'package:daily_dose_mobile/services/appointment_service.dart';
import 'package:daily_dose_mobile/services/auth_service.dart';
import 'package:daily_dose_mobile/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Test-specific FirestoreService that uses FakeFirestore
class _TestFirestoreService extends FirestoreService {
  _TestFirestoreService(this._fakeFirestore)
      : super.forTesting();

  final FakeFirebaseFirestore _fakeFirestore;

  @override
  CollectionReference get users {
    return _fakeFirestore.collection('users');
  }
}

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MockFirebaseAuth mockAuth;
  late AppointmentService appointmentService;
  const String testUid = 'test-user-123';

  setUpAll(() async {
    // Create shared instances that will be reused across all tests
    fakeFirestore = FakeFirebaseFirestore();
    mockAuth = MockFirebaseAuth();

    // Create a mock user
    await mockAuth.createUserWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
    );

    // Mock the services using testing methods
    AuthService.setInstanceForTesting(mockAuth);

    final firestoreService = _TestFirestoreService(fakeFirestore);
    FirestoreService.setInstanceForTesting(firestoreService);

    appointmentService = AppointmentService.instance;
  });

  tearDown(() async {
    // Clear all appointments for this user after each test
    final userDoc = fakeFirestore.collection('users').doc(testUid);
    final appointments = await userDoc.collection('appointments').get();
    for (var doc in appointments.docs) {
      await doc.reference.delete();
    }
  });

  group('Appointment Tracking Feature Tests', () {
    // ==================== ADD APPOINTMENT ====================
    group('Add Appointment', () {
      test('Should create a new appointment successfully', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Sarah Johnson',
          specialty: 'Cardiology',
          appointmentDateTime: DateTime.now().add(const Duration(days: 7)),
          durationMinutes: 60,
          visitType: 'Telehealth',
          reason: 'Routine heart check-up',
          status: 'upcoming',
          location: null,
          meetingLink: 'https://zoom.us/j/123456789',
          avatarLabel: 'SJ',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        expect(savedAppointment.id.isNotEmpty, true);
        expect(savedAppointment.doctorName, 'Dr. Sarah Johnson');
        expect(savedAppointment.specialty, 'Cardiology');
        expect(savedAppointment.visitType, 'Telehealth');
        expect(savedAppointment.reason, 'Routine heart check-up');
        expect(savedAppointment.status, 'upcoming');
        expect(savedAppointment.meetingLink, 'https://zoom.us/j/123456789');
      });

      test('Should handle in-person appointments', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Robert Smith',
          specialty: 'Orthopedics',
          appointmentDateTime: DateTime.now().add(const Duration(days: 14)),
          durationMinutes: 45,
          visitType: 'In-Person',
          reason: 'Knee injury consultation',
          status: 'upcoming',
          location: '123 Medical Center Blvd, Suite 200',
          meetingLink: null,
          avatarLabel: 'RS',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        expect(savedAppointment.visitType, 'In-Person');
        expect(savedAppointment.location, '123 Medical Center Blvd, Suite 200');
        expect(savedAppointment.meetingLink, null);
      });

      test('Should create appointment with AI summary enabled', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Emily Chen',
          specialty: 'Dermatology',
          appointmentDateTime: DateTime.now().add(const Duration(days: 3)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Skin consultation',
          status: 'upcoming',
          location: null,
          meetingLink: 'https://zoom.us/j/987654321',
          avatarLabel: 'EC',
          isAiSummaryEnabled: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        expect(savedAppointment.isAiSummaryEnabled, true);
      });

      test('Should handle appointments without AI summary', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Michael Brown',
          specialty: 'Psychiatry',
          appointmentDateTime: DateTime.now().add(const Duration(days: 5)),
          durationMinutes: 50,
          visitType: 'Telehealth',
          reason: 'Monthly therapy session',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'MB',
          isAiSummaryEnabled: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        expect(savedAppointment.isAiSummaryEnabled, false);
      });
    });

    // ==================== EDIT APPOINTMENT ====================
    group('Edit Appointment', () {
      test('Should update an existing appointment', () async {
        // Create initial appointment
        final initialAppointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Sarah Johnson',
          specialty: 'Cardiology',
          appointmentDateTime: DateTime.now().add(const Duration(days: 7)),
          durationMinutes: 60,
          visitType: 'Telehealth',
          reason: 'Routine heart check-up',
          status: 'upcoming',
          location: null,
          meetingLink: 'https://zoom.us/j/123456789',
          avatarLabel: 'SJ',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: initialAppointment,
        );

        // Update the appointment
        final updatedAppointment = savedAppointment.copyWith(
          reason: 'Updated reason: Advanced cardiology consultation',
          durationMinutes: 90,
        );

        final result = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: updatedAppointment,
        );

        expect(result.id, savedAppointment.id);
        expect(result.reason, 'Updated reason: Advanced cardiology consultation');
        expect(result.durationMinutes, 90);
        expect(result.doctorName, 'Dr. Sarah Johnson');
      });

      test('Should change appointment date and time', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Lisa Martinez',
          specialty: 'Neurology',
          appointmentDateTime: DateTime.now().add(const Duration(days: 10)),
          durationMinutes: 45,
          visitType: 'In-Person',
          reason: 'Migraine evaluation',
          status: 'upcoming',
          location: '456 Medical Plaza',
          meetingLink: null,
          avatarLabel: 'LM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Reschedule appointment
        final newDateTime = DateTime.now().add(const Duration(days: 15));
        final rescheduledAppointment = savedAppointment.copyWith(
          appointmentDateTime: newDateTime,
        );

        final result = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: rescheduledAppointment,
        );

        expect(result.appointmentDateTime.day, newDateTime.day);
        expect(result.appointmentDateTime.month, newDateTime.month);
      });

      test('Should change appointment type from telehealth to in-person', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. James Wilson',
          specialty: 'General Practice',
          appointmentDateTime: DateTime.now().add(const Duration(days: 5)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Flu shot',
          status: 'upcoming',
          location: null,
          meetingLink: 'https://zoom.us/j/111111111',
          avatarLabel: 'JW',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Change to in-person (create a new appointment record for clean state)
        final updatedAppointment = savedAppointment.copyWith(
          visitType: 'In-Person',
          location: '789 Clinic Drive',
        );

        final result = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: updatedAppointment,
        );

        expect(result.visitType, 'In-Person');
        expect(result.location, '789 Clinic Drive');
        // Verify the update happened by checking Firestore
        final updated = await appointmentService
            .watchAppointments(uid: testUid)
            .first;
        final apt = updated.firstWhere((a) => a.id == result.id);
        expect(apt.visitType, 'In-Person');
      });
    });

    // ==================== DELETE APPOINTMENT ====================
    group('Delete Appointment', () {
      test('Should delete an appointment', () async {
        // Create appointment
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Patricia Allen',
          specialty: 'Ophthalmology',
          appointmentDateTime: DateTime.now().add(const Duration(days: 3)),
          durationMinutes: 30,
          visitType: 'In-Person',
          reason: 'Eye exam',
          status: 'upcoming',
          location: '321 Eye Care Center',
          meetingLink: null,
          avatarLabel: 'PA',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final savedAppointment = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Delete the appointment
        await appointmentService.deleteAppointment(
          uid: testUid,
          appointmentId: savedAppointment.id,
        );

        // Verify deletion by checking stream
        final appointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        expect(
          appointments.any((apt) => apt.id == savedAppointment.id),
          false,
        );
      });

      test('Should handle deleting non-existent appointment gracefully', () async {
        // Attempting to delete a non-existent appointment should complete without error
        try {
          await appointmentService.deleteAppointment(
            uid: testUid,
            appointmentId: 'non-existent-id',
          );
          // If we reach here, the delete completed successfully
          expect(true, true);
        } catch (e) {
          // If an exception is thrown, fail the test
          fail('Should not throw exception: $e');
        }
      });
    });

    // ==================== APPOINTMENT STREAM & TIMELINE ====================
    group('Appointment Timeline & Stream', () {
      test('Should return all appointments in stream', () async {
        // Create multiple appointments
        final appointments = [
          AppointmentModel(
            id: '',
            doctorName: 'Dr. Sarah Johnson',
            specialty: 'Cardiology',
            appointmentDateTime: DateTime.now().add(const Duration(days: 7)),
            durationMinutes: 60,
            visitType: 'Telehealth',
            reason: 'Heart check-up',
            status: 'upcoming',
            location: null,
            meetingLink: 'https://zoom.us/j/1',
            avatarLabel: 'SJ',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          AppointmentModel(
            id: '',
            doctorName: 'Dr. Robert Smith',
            specialty: 'Orthopedics',
            appointmentDateTime: DateTime.now().add(const Duration(days: 14)),
            durationMinutes: 45,
            visitType: 'In-Person',
            reason: 'Knee consultation',
            status: 'upcoming',
            location: 'Medical Center',
            meetingLink: null,
            avatarLabel: 'RS',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          AppointmentModel(
            id: '',
            doctorName: 'Dr. Emily Chen',
            specialty: 'Dermatology',
            appointmentDateTime: DateTime.now().add(const Duration(days: 3)),
            durationMinutes: 30,
            visitType: 'Telehealth',
            reason: 'Skin consultation',
            status: 'upcoming',
            location: null,
            meetingLink: 'https://zoom.us/j/3',
            avatarLabel: 'EC',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        for (var apt in appointments) {
          await appointmentService.saveAppointment(
            uid: testUid,
            appointment: apt,
          );
        }

        // Get appointments from stream
        final streamAppointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        expect(streamAppointments.length, 3);
        expect(
          streamAppointments.every((apt) => apt.id.isNotEmpty),
          true,
        );
      });

      test('Should return appointments ordered by datetime', () async {
        final now = DateTime.now();
        final apt1 = AppointmentModel(
          id: '',
          doctorName: 'Dr. First',
          specialty: 'Specialty1',
          appointmentDateTime: now.add(const Duration(days: 10)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Reason 1',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'F',
          createdAt: now,
          updatedAt: now,
        );

        final apt2 = AppointmentModel(
          id: '',
          doctorName: 'Dr. Second',
          specialty: 'Specialty2',
          appointmentDateTime: now.add(const Duration(days: 5)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Reason 2',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'S',
          createdAt: now,
          updatedAt: now,
        );

        await appointmentService.saveAppointment(uid: testUid, appointment: apt1);
        await appointmentService.saveAppointment(uid: testUid, appointment: apt2);

        final appointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        expect(appointments.length, 2);
        // Should be ordered by appointmentDateTime (apt2 before apt1)
        expect(
          appointments[0].appointmentDateTime.isBefore(appointments[1].appointmentDateTime),
          true,
        );
      });

      test('Should reflect changes in stream when appointment is updated', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Update Test',
          specialty: 'Test Specialty',
          appointmentDateTime: DateTime.now().add(const Duration(days: 5)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Test Reason',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'UT',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Get initial stream value
        final initial = await appointmentService
            .watchAppointments(uid: testUid)
            .first;
        expect(initial.length, 1);

        // Update the appointment
        final updated = saved.copyWith(
          reason: 'Updated Test Reason',
        );

        await appointmentService.saveAppointment(
          uid: testUid,
          appointment: updated,
        );

        // Get updated stream value
        final afterUpdate = await appointmentService
            .watchAppointments(uid: testUid)
            .first;
        expect(afterUpdate[0].reason, 'Updated Test Reason');
      });
    });

    // ==================== UPCOMING VS PAST LOGIC ====================
    group('Upcoming vs Past Logic', () {
      test('Should identify upcoming appointments correctly', () {
        final now = DateTime.now();
        final futureAppointment = AppointmentModel(
          id: 'future-1',
          doctorName: 'Dr. Future',
          specialty: 'Test',
          appointmentDateTime: now.add(const Duration(days: 5)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Future appointment',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'F',
          createdAt: now,
          updatedAt: now,
        );

        final isUpcoming = !futureAppointment.isCompleted &&
            futureAppointment.appointmentDateTime.isAfter(now);

        expect(isUpcoming, true);
      });

      test('Should identify past appointments correctly', () {
        final now = DateTime.now();
        final pastAppointment = AppointmentModel(
          id: 'past-1',
          doctorName: 'Dr. Past',
          specialty: 'Test',
          appointmentDateTime: now.subtract(const Duration(days: 5)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Past appointment',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'P',
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
        );

        final isPast = pastAppointment.isCompleted ||
            pastAppointment.appointmentDateTime.isBefore(now);

        expect(isPast, true);
      });

      test('Should identify completed appointments as past', () {
        final now = DateTime.now();
        final completedAppointment = AppointmentModel(
          id: 'completed-1',
          doctorName: 'Dr. Completed',
          specialty: 'Test',
          appointmentDateTime: now.subtract(const Duration(days: 3)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Completed appointment',
          status: 'completed',
          completionNotes: 'Everything looks good.',
          completedAt: now.subtract(const Duration(days: 3)),
          location: null,
          meetingLink: null,
          avatarLabel: 'C',
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now,
        );

        final isPast = completedAppointment.isCompleted ||
            completedAppointment.appointmentDateTime.isBefore(now);

        expect(isPast, true);
        expect(completedAppointment.isCompleted, true);
      });

      test('Should correctly filter appointments by upcoming/past', () async {
        final now = DateTime.now();

        // Create upcoming appointment
        final upcoming = AppointmentModel(
          id: '',
          doctorName: 'Dr. Future',
          specialty: 'Test',
          appointmentDateTime: now.add(const Duration(days: 7)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Upcoming',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'U',
          createdAt: now,
          updatedAt: now,
        );

        // Create past appointment
        final past = AppointmentModel(
          id: '',
          doctorName: 'Dr. History',
          specialty: 'Test',
          appointmentDateTime: now.subtract(const Duration(days: 7)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Past',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'P',
          createdAt: now.subtract(const Duration(days: 14)),
          updatedAt: now.subtract(const Duration(days: 14)),
        );

        await appointmentService.saveAppointment(
          uid: testUid,
          appointment: upcoming,
        );
        await appointmentService.saveAppointment(
          uid: testUid,
          appointment: past,
        );

        final allAppointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        // Filter upcoming (like the screen does)
        final upcomingFiltered = allAppointments.where((apt) {
          final isPast = apt.isCompleted || apt.appointmentDateTime.isBefore(now);
          return !isPast;
        }).toList();

        // Filter past (like the screen does)
        final pastFiltered = allAppointments.where((apt) {
          final isPast = apt.isCompleted || apt.appointmentDateTime.isBefore(now);
          return isPast;
        }).toList();

        expect(upcomingFiltered.length, 1);
        expect(pastFiltered.length, 1);
      });
    });

    // ==================== APPOINTMENT COMPLETION & STATUS ====================
    group('Appointment Completion & Status', () {
      test('Should complete an appointment with notes', () async {
        // Create appointment
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Completion Test',
          specialty: 'Test Specialty',
          appointmentDateTime: DateTime.now().subtract(const Duration(hours: 2)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Test appointment',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'CT',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Complete appointment with notes
        await appointmentService.completeAppointment(
          uid: testUid,
          appointmentId: saved.id,
          completionNotes: 'Doctor provided medication recommendations.',
        );

        // Verify completion
        final appointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        final completed = appointments.firstWhere((apt) => apt.id == saved.id);

        expect(completed.status, 'completed');
        expect(completed.completionNotes, 'Doctor provided medication recommendations.');
        expect(completed.completedAt, isNotNull);
      });

      test('Should track completion timestamp', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Timestamp Test',
          specialty: 'Test',
          appointmentDateTime: DateTime.now().subtract(const Duration(hours: 1)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Test',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'TT',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        final beforeCompletion = DateTime.now().toUtc();

        await appointmentService.completeAppointment(
          uid: testUid,
          appointmentId: saved.id,
          completionNotes: 'Test notes',
        );

        final afterCompletion = DateTime.now().toUtc();

        final appointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        final completed = appointments.firstWhere((apt) => apt.id == saved.id);

        expect(completed.completedAt, isNotNull);
        expect(
          completed.completedAt!.isAfter(beforeCompletion.subtract(const Duration(seconds: 5))),
          true,
        );
        expect(
          completed.completedAt!.isBefore(afterCompletion.add(const Duration(seconds: 5))),
          true,
        );
      });

      test('Should mark appointment as isCompleted', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Complete Flag',
          specialty: 'Test',
          appointmentDateTime: DateTime.now().subtract(const Duration(hours: 1)),
          durationMinutes: 30,
          visitType: 'Telehealth',
          reason: 'Test',
          status: 'upcoming',
          location: null,
          meetingLink: null,
          avatarLabel: 'CF',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(days: 3)),
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        expect(saved.isCompleted, false);

        await appointmentService.completeAppointment(
          uid: testUid,
          appointmentId: saved.id,
          completionNotes: 'Completed',
        );

        final appointments = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        final completed = appointments.firstWhere((apt) => apt.id == saved.id);

        expect(completed.isCompleted, true);
      });
    });

    // ==================== REMINDERS & NOTIFICATIONS ====================
    group('Appointment Reminders & Notifications', () {
      test('Should handle appointment with notification-friendly data', () async {
        final now = DateTime.now();
        final appointmentTime = now.add(const Duration(hours: 24));

        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Notification Test',
          specialty: 'Dentistry',
          appointmentDateTime: appointmentTime,
          durationMinutes: 30,
          visitType: 'In-Person',
          reason: 'Dental checkup',
          status: 'upcoming',
          location: '789 Dental Plaza',
          meetingLink: null,
          avatarLabel: 'DN',
          createdAt: now,
          updatedAt: now,
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        // Verify data needed for notifications is present
        expect(saved.id.isNotEmpty, true);
        expect(saved.doctorName.isNotEmpty, true);
        expect(saved.appointmentDateTime, isNotNull);
        expect(saved.location != null || saved.meetingLink != null, true);
      });

      test('Should preserve appointment data for reminder scheduling', () async {
        final appointment = AppointmentModel(
          id: '',
          doctorName: 'Dr. Reminder Test',
          specialty: 'Cardiology',
          appointmentDateTime: DateTime.now().add(const Duration(hours: 2)),
          durationMinutes: 60,
          visitType: 'Telehealth',
          reason: 'Heart checkup',
          status: 'upcoming',
          location: null,
          meetingLink: 'https://zoom.us/j/reminder-test',
          avatarLabel: 'RT',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final saved = await appointmentService.saveAppointment(
          uid: testUid,
          appointment: appointment,
        );

        final retrieved = await appointmentService
            .watchAppointments(uid: testUid)
            .first;

        final apt = retrieved.firstWhere((a) => a.id == saved.id);

        // All data needed for reminders should be preserved
        expect(apt.doctorName, 'Dr. Reminder Test');
        expect(apt.appointmentDateTime, isNotNull);
        expect(apt.meetingLink, 'https://zoom.us/j/reminder-test');
        expect(apt.status, 'upcoming');
      });
    });
  });
}
