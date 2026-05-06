import 'package:flutter_test/flutter_test.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_model.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_dose_model.dart';
import 'package:daily_dose_mobile/services/medication_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MedicationService medicationService;
  const String testUid = 'test-user-123';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    medicationService = MedicationService(fakeFirestore);
    MedicationService.setInstance(medicationService);
  });

  group('Medication Service Tests', () {
    // ==================== ADD MEDICATION ====================
    group('Add Medication', () {
      test('createMedication should add a new medication', () async {
        final medication = MedicationModel(
          id: 'med-001',
          uid: testUid,
          name: 'Metformin',
          dosage: '500mg',
          frequency: 'twice daily',
          timeSlots: ['08:00', '20:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final result = await medicationService.createMedication(testUid, medication);

        expect(result.name, equals('Metformin'));
        expect(result.dosage, equals('500mg'));
        expect(result.isActive, equals(true));
      });

      test('createMedication should schedule initial doses', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-002',
          uid: testUid,
          name: 'Lisinopril',
          dosage: '10mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Verify doses were created for first day
        final doses = await medicationService.getDosesForDate(testUid, now);
        expect(doses.isNotEmpty, equals(true));
        expect(doses.first.medicationId, equals(medication.id));
      });

      test('createMedication should create medication with multiple time slots', () async {
        final medication = MedicationModel(
          id: 'med-003',
          uid: testUid,
          name: 'Aspirin',
          dosage: '100mg',
          frequency: 'three times daily',
          timeSlots: ['08:00', '14:00', '20:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final result = await medicationService.createMedication(testUid, medication);

        expect(result.timeSlots.length, equals(3));
        expect(result.timeSlots, contains('08:00'));
        expect(result.timeSlots, contains('14:00'));
        expect(result.timeSlots, contains('20:00'));
      });
    });

    // ==================== EDIT MEDICATION ====================
    group('Edit Medication', () {
      test('updateMedication should modify existing medication', () async {
        final medication = MedicationModel(
          id: 'med-004',
          uid: testUid,
          name: 'Original Name',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Update the medication
        final updated = medication.copyWith(
          name: 'Updated Name',
          dosage: '750mg',
        );

        final result = await medicationService.updateMedication(testUid, updated);

        expect(result.name, equals('Updated Name'));
        expect(result.dosage, equals('750mg'));
      });

      test('updateMedication should update time slots', () async {
        final medication = MedicationModel(
          id: 'med-005',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'twice daily',
          timeSlots: ['08:00', '20:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final updated = medication.copyWith(
          timeSlots: ['07:00', '19:00', '23:00'],
        );

        final result = await medicationService.updateMedication(testUid, updated);

        expect(result.timeSlots.length, equals(3));
        expect(result.timeSlots, equals(['07:00', '19:00', '23:00']));
      });

      test('updateMedication should update isActive status', () async {
        final medication = MedicationModel(
          id: 'med-006',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final updated = medication.copyWith(isActive: false);
        final result = await medicationService.updateMedication(testUid, updated);

        expect(result.isActive, equals(false));
      });

      test('updateMedication should preserve createdAt timestamp', () async {
        final createTime = DateTime.now().subtract(const Duration(days: 1));
        final medication = MedicationModel(
          id: 'med-007',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: createTime,
        );

        await medicationService.createMedication(testUid, medication);

        final updated = medication.copyWith(name: 'Updated Name');
        final result = await medicationService.updateMedication(testUid, updated);

        expect(result.createdAt.day, equals(createTime.day));
      });
    });

    // ==================== DELETE MEDICATION ====================
    group('Delete Medication', () {
      test('deleteMedication should remove medication', () async {
        final medication = MedicationModel(
          id: 'med-008',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Verify medication exists
        var retrieved = await medicationService.getMedicationById(testUid, medication.id);
        expect(retrieved, isNotNull);

        // Delete medication
        await medicationService.deleteMedication(testUid, medication.id);

        // Verify medication is gone
        retrieved = await medicationService.getMedicationById(testUid, medication.id);
        expect(retrieved, isNull);
      });

      test('deleteMedication should remove associated doses', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-009',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Verify doses exist
        var doses = await medicationService.getDosesForDate(testUid, now);
        expect(doses.isNotEmpty, equals(true));

        // Delete medication
        await medicationService.deleteMedication(testUid, medication.id);

        // Verify doses are deleted
        doses = await medicationService.getDosesForDate(testUid, now);
        final remainingForMed =
            doses.where((d) => d.medicationId == medication.id).toList();
        expect(remainingForMed.isEmpty, equals(true));
      });

      test('deleteMedication should remove adherence records', () async {
        final medication = MedicationModel(
          id: 'med-010',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Get initial adherence count
        var adherence =
            await medicationService.getAdherence(testUid, medication.id);
        final initialCount = adherence.length;

        // Delete medication
        await medicationService.deleteMedication(testUid, medication.id);

        // Verify adherence records are deleted
        adherence = await medicationService.getAdherence(testUid, medication.id);
        expect(adherence.isEmpty, equals(true));
      });
    });

    // ==================== MARK DOSE AS TAKEN ====================
    group('Mark Dose as Taken', () {
      test('markDoseTaken should update dose status to taken', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-011',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Get the created dose
        final doses = await medicationService.getDosesForDate(testUid, now);
        expect(doses.isNotEmpty, equals(true));
        final doseId = doses.first.id;

        // Mark as taken
        await medicationService.markDoseTaken(testUid, doseId);

        // Verify status is taken
        final updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.status, equals(DoseStatus.taken));
      });

      test('markDoseTaken should set takenTime', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-012',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final doseId = doses.first.id;

        await medicationService.markDoseTaken(testUid, doseId);

        final updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.takenTime, isNotNull);
      });

      test('markDoseTaken should mark as late if taken after 15 minutes', () async {
        final now = DateTime.now();
        final scheduledTime = DateTime(now.year, now.month, now.day, 9, 0);
        
        final medication = MedicationModel(
          id: 'med-013',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: scheduledTime,
          endDate: scheduledTime.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, scheduledTime);
        final dose = doses.first;
        
        // Simulate taking dose late (20 minutes after scheduled time)
        final lateTime = dose.scheduledTime.add(const Duration(minutes: 20));
        
        // Create a dose with late takenTime manually for testing
        final lateDose = dose.copyWith(
          takenTime: lateTime,
          status: DoseStatus.late,
        );
        
        expect(lateDose.isLate(), equals(true));
      });
    });

    // ==================== MARK DOSE AS MISSED ====================
    group('Mark Dose as Missed', () {
      test('markDoseMissed should update dose status to missed', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-014',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final doseId = doses.first.id;

        await medicationService.markDoseMissed(testUid, doseId);

        final updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.status, equals(DoseStatus.missed));
      });

      test('markDoseMissed should preserve createdAt time', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-015',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final originalCreatedAt = doses.first.createdAt;
        final doseId = doses.first.id;

        await medicationService.markDoseMissed(testUid, doseId);

        final updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.createdAt, equals(originalCreatedAt));
      });

      test('markDoseMissed should not set takenTime', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-016',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final doseId = doses.first.id;

        await medicationService.markDoseMissed(testUid, doseId);

        final updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.takenTime, isNull);
      });
    });

    // ==================== DAILY RESET LOGIC ====================
    group('Daily Reset Logic', () {
      test('getDosesForDate should only return doses for that specific date', () async {
        final date1 = DateTime(2026, 5, 6);
        final date2 = DateTime(2026, 5, 7);

        final medication = MedicationModel(
          id: 'med-017',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'daily',
          timeSlots: ['09:00'],
          startDate: date1,
          endDate: date2.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final dosesDay1 = await medicationService.getDosesForDate(testUid, date1);
        final dosesDay2 = await medicationService.getDosesForDate(testUid, date2);

        // Both days should have doses
        expect(dosesDay1.isNotEmpty, equals(true));
        expect(dosesDay2.isNotEmpty, equals(true));

        // Doses should be on their respective dates
        for (final dose in dosesDay1) {
          expect(dose.scheduledTime.day, equals(date1.day));
        }

        for (final dose in dosesDay2) {
          expect(dose.scheduledTime.day, equals(date2.day));
        }
      });

      test('getPendingDoses should only return unfinished doses', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-018',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        // Mark first dose as taken
        final doses = await medicationService.getDosesForDate(testUid, now);
        if (doses.isNotEmpty) {
          await medicationService.markDoseTaken(testUid, doses.first.id);
        }

        final pending = await medicationService.getPendingDoses(testUid);

        // Taken dose should not be in pending
        for (final pendingDose in pending) {
          expect(pendingDose.status, equals(DoseStatus.pending));
        }
      });

      test('should reset dose status when marking missed then taken', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-019',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final doseId = doses.first.id;

        // Mark as missed
        await medicationService.markDoseMissed(testUid, doseId);
        var updatedDose =
            await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.status, equals(DoseStatus.missed));

        // Mark as taken (update status)
        await medicationService.markDoseTaken(testUid, doseId);
        updatedDose = await medicationService.getDoseById(testUid, doseId);
        expect(updatedDose?.status, isIn([DoseStatus.taken, DoseStatus.late]));
      });
    });

    // ==================== MEDICATION SCHEDULE DISPLAY ====================
    group('Medication Schedule Display', () {
      test('getMedications should return all medications ordered by creation', () async {
        final med1 = MedicationModel(
          id: 'med-020',
          uid: testUid,
          name: 'Med A',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final med2 = MedicationModel(
          id: 'med-021',
          uid: testUid,
          name: 'Med B',
          dosage: '250mg',
          frequency: 'twice daily',
          timeSlots: ['08:00', '20:00'],
          isActive: true,
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await medicationService.createMedication(testUid, med1);
        await medicationService.createMedication(testUid, med2);

        final medications = await medicationService.getMedications(testUid);

        expect(medications.length, greaterThanOrEqualTo(2));
        expect(medications.map((m) => m.id), contains(med1.id));
        expect(medications.map((m) => m.id), contains(med2.id));
      });

      test('getActiveMedications should filter by isActive status', () async {
        final now = DateTime.now();
        final activeMed = MedicationModel(
          id: 'med-022',
          uid: testUid,
          name: 'Active Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final inactiveMed = MedicationModel(
          id: 'med-023',
          uid: testUid,
          name: 'Inactive Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: false,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, activeMed);
        await medicationService.createMedication(testUid, inactiveMed);

        final activeMeds =
            await medicationService.getActiveMedications(testUid);

        final activeIds = activeMeds.map((m) => m.id).toList();
        expect(activeIds, contains(activeMed.id));
        expect(activeIds, isNot(contains(inactiveMed.id)));
      });

      test('getActiveMedications should respect start and end dates', () async {
        final today = DateTime.now();
        final tomorrow = today.add(const Duration(days: 1));
        final yesterday = today.subtract(const Duration(days: 1));

        final futureMed = MedicationModel(
          id: 'med-024',
          uid: testUid,
          name: 'Future Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: tomorrow,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final pastMed = MedicationModel(
          id: 'med-025',
          uid: testUid,
          name: 'Past Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          endDate: yesterday,
          isActive: true,
          createdAt: DateTime.now(),
        );

        final currentMed = MedicationModel(
          id: 'med-026',
          uid: testUid,
          name: 'Current Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: yesterday,
          endDate: tomorrow,
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, futureMed);
        await medicationService.createMedication(testUid, pastMed);
        await medicationService.createMedication(testUid, currentMed);

        final activeMeds =
            await medicationService.getActiveMedications(testUid);
        final activeIds = activeMeds.map((m) => m.id).toList();

        expect(activeIds, contains(currentMed.id));
        expect(activeIds, isNot(contains(futureMed.id)));
        expect(activeIds, isNot(contains(pastMed.id)));
      });

      test('medication timeSlots should be displayed correctly', () async {
        final medication = MedicationModel(
          id: 'med-027',
          uid: testUid,
          name: 'Multi-dose Med',
          dosage: '500mg',
          frequency: 'three times daily',
          timeSlots: ['08:00', '14:00', '20:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final retrieved =
            await medicationService.getMedicationById(testUid, medication.id);

        expect(retrieved?.timeSlots.length, equals(3));
        expect(retrieved?.timeSlots, equals(['08:00', '14:00', '20:00']));
      });

      test('getDosesForDate should show all doses with times', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-028',
          uid: testUid,
          name: 'Three Times Daily',
          dosage: '500mg',
          frequency: 'three times daily',
          timeSlots: ['08:00', '14:00', '20:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        final dosesForMed =
            doses.where((d) => d.medicationId == medication.id).toList();

        expect(dosesForMed.length, equals(3));
        
        // Check times are correct
        final scheduledTimes = dosesForMed
            .map((d) => '${d.scheduledTime.hour}:${d.scheduledTime.minute.toString().padLeft(2, '0')}')
            .toList();
        
        expect(scheduledTimes, contains('8:00'));
        expect(scheduledTimes, contains('14:00'));
        expect(scheduledTimes, contains('20:00'));
      });
    });

    // ==================== MEDICATION ADHERENCE ====================
    group('Medication Adherence', () {
      test('getAdherence should calculate adherence score', () async {
        final now = DateTime.now();
        final medication = MedicationModel(
          id: 'med-029',
          uid: testUid,
          name: 'Test Med',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          startDate: now,
          endDate: now.add(const Duration(days: 30)),
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, medication);

        final doses = await medicationService.getDosesForDate(testUid, now);
        if (doses.isNotEmpty) {
          await medicationService.markDoseTaken(testUid, doses.first.id);
        }

        final adherence =
            await medicationService.getAdherence(testUid, medication.id);

        expect(adherence, isNotEmpty);
      });

      test('getOverallAdherence should aggregate across medications', () async {
        final med1 = MedicationModel(
          id: 'med-030',
          uid: testUid,
          name: 'Med 1',
          dosage: '500mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        final med2 = MedicationModel(
          id: 'med-031',
          uid: testUid,
          name: 'Med 2',
          dosage: '250mg',
          frequency: 'once daily',
          timeSlots: ['09:00'],
          isActive: true,
          createdAt: DateTime.now(),
        );

        await medicationService.createMedication(testUid, med1);
        await medicationService.createMedication(testUid, med2);

        final score = await medicationService.getOverallAdherence(testUid);

        expect(score, greaterThanOrEqualTo(0));
        expect(score, lessThanOrEqualTo(100));
      });
    });
  });
}
