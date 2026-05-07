import 'package:flutter_test/flutter_test.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_model.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_dose_model.dart';
import 'package:daily_dose_mobile/features/medications/models/medication_adherence_model.dart';
import 'package:daily_dose_mobile/services/medication_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late MedicationService medicationService;
  const String testUid = 'test-user-adherence';

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    medicationService = MedicationService(fakeFirestore);
    MedicationService.setInstance(medicationService);
  });

  group('Adherence Tracking Feature Tests', () {
    // ==================== ADHERENCE PERCENTAGE CALCULATION ====================
    group('Adherence Percentage Calculation', () {
      test('should calculate 100% adherence when all doses taken on time', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 1,
          takenDoses: 1,
          lateDoses: 0,
        );
        expect(score, equals(100.0));
      });

      test('should calculate 50% adherence when all doses are late', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 2,
          takenDoses: 2,
          lateDoses: 2,
        );
        expect(score, equals(50.0));
      });

      test('should calculate 75% adherence with mixed on-time and late doses', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 4,
          takenDoses: 4,
          lateDoses: 2,
        );
        // Expected: (4 - 2 + 2*0.5) / 4 * 100 = (2 + 1) / 4 * 100 = 75%
        expect(score, equals(75.0));
      });

      test('should calculate 0% adherence when no doses taken', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 3,
          takenDoses: 0,
          lateDoses: 0,
        );
        expect(score, equals(0.0));
      });

      test('should calculate 50% with 1 of 2 doses on time', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 2,
          takenDoses: 1,
          lateDoses: 0,
        );
        expect(score, equals(50.0));
      });

      test('should handle 0 total doses without error', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 0,
          takenDoses: 0,
          lateDoses: 0,
        );
        expect(score, equals(100.0)); // Safe default for no doses
      });

      test('should clamp score between 0 and 100', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 1,
          takenDoses: 1,
          lateDoses: 0,
        );
        expect(score, lessThanOrEqualTo(100.0));
        expect(score, greaterThanOrEqualTo(0.0));
      });

      test('should calculate status Excellent for 90%+ score', () {
        final adherence = MedicationAdherenceModel(
          id: 'adh-1',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          date: DateTime.now(),
          totalDoses: 1,
          takenDoses: 1,
          missedDoses: 0,
          lateDoses: 0,
          missedStreak: 0,
          adherenceScore: 95.0,
          createdAt: DateTime.now(),
        );
        expect(adherence.getStatus(), equals('Excellent'));
      });

      test('should calculate status Good for 75-89%', () {
        final adherence = MedicationAdherenceModel(
          id: 'adh-2',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          date: DateTime.now(),
          totalDoses: 1,
          takenDoses: 1,
          missedDoses: 0,
          lateDoses: 0,
          missedStreak: 0,
          adherenceScore: 80.0,
          createdAt: DateTime.now(),
        );
        expect(adherence.getStatus(), equals('Good'));
      });

      test('should calculate status Fair for 50-74%', () {
        final adherence = MedicationAdherenceModel(
          id: 'adh-3',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          date: DateTime.now(),
          totalDoses: 1,
          takenDoses: 1,
          missedDoses: 0,
          lateDoses: 0,
          missedStreak: 0,
          adherenceScore: 60.0,
          createdAt: DateTime.now(),
        );
        expect(adherence.getStatus(), equals('Fair'));
      });

      test('should calculate status Poor for <50%', () {
        final adherence = MedicationAdherenceModel(
          id: 'adh-4',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          date: DateTime.now(),
          totalDoses: 1,
          takenDoses: 1,
          missedDoses: 0,
          lateDoses: 0,
          missedStreak: 0,
          adherenceScore: 30.0,
          createdAt: DateTime.now(),
        );
        expect(adherence.getStatus(), equals('Poor'));
      });

      test('should return correct color status', () {
        final excellent = MedicationAdherenceModel(
          id: 'c1', uid: testUid, medicationId: 'm1', medicationName: 'M',
          date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
          lateDoses: 0, missedStreak: 0, adherenceScore: 95.0, createdAt: DateTime.now(),
        );
        expect(excellent.getColorStatus(), equals('excellent'));

        final good = MedicationAdherenceModel(
          id: 'c2', uid: testUid, medicationId: 'm1', medicationName: 'M',
          date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
          lateDoses: 0, missedStreak: 0, adherenceScore: 80.0, createdAt: DateTime.now(),
        );
        expect(good.getColorStatus(), equals('good'));

        final fair = MedicationAdherenceModel(
          id: 'c3', uid: testUid, medicationId: 'm1', medicationName: 'M',
          date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
          lateDoses: 0, missedStreak: 0, adherenceScore: 50.0, createdAt: DateTime.now(),
        );
        expect(fair.getColorStatus(), equals('fair'));

        final poor = MedicationAdherenceModel(
          id: 'c4', uid: testUid, medicationId: 'm1', medicationName: 'M',
          date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
          lateDoses: 0, missedStreak: 0, adherenceScore: 30.0, createdAt: DateTime.now(),
        );
        expect(poor.getColorStatus(), equals('poor'));
      });
    });

    // ==================== DOSE STATUS TRACKING ====================
    group('Dose Status Tracking', () {
      test('should track dose marked as taken', () {
        final dose = MedicationDoseModel(
          id: 'dose-1',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          dosage: '500mg',
          scheduledTime: DateTime.now(),
          status: DoseStatus.taken,
          createdAt: DateTime.now(),
        );

        expect(dose.status, equals(DoseStatus.taken));
      });

      test('should track dose marked as missed', () {
        final dose = MedicationDoseModel(
          id: 'dose-2',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          dosage: '500mg',
          scheduledTime: DateTime.now(),
          status: DoseStatus.missed,
          createdAt: DateTime.now(),
        );

        expect(dose.status, equals(DoseStatus.missed));
      });

      test('should track dose marked as late', () {
        final dose = MedicationDoseModel(
          id: 'dose-3',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          dosage: '500mg',
          scheduledTime: DateTime.now(),
          status: DoseStatus.late,
          createdAt: DateTime.now(),
        );

        expect(dose.status, equals(DoseStatus.late));
      });

      test('should default to pending status', () {
        final dose = MedicationDoseModel(
          id: 'dose-4',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          dosage: '500mg',
          scheduledTime: DateTime.now(),
          status: DoseStatus.pending,
          createdAt: DateTime.now(),
        );

        expect(dose.status, equals(DoseStatus.pending));
      });

      test('should detect late dose correctly', () {
        final scheduledTime = DateTime.now().subtract(const Duration(minutes: 20));
        final takenTime = scheduledTime.add(const Duration(minutes: 20)); // 20 min late

        final dose = MedicationDoseModel(
          id: 'dose-5',
          uid: testUid,
          medicationId: 'med-1',
          medicationName: 'Test Med',
          dosage: '500mg',
          scheduledTime: scheduledTime,
          takenTime: takenTime,
          status: DoseStatus.late,
          createdAt: DateTime.now(),
        );

        expect(dose.isLate(), equals(true));
      });
    });

    // ==================== ADHERENCE MODEL ====================
    group('Adherence Model', () {
      test('should create adherence record with correct data', () {
        final date = DateTime.now();
        final adherence = MedicationAdherenceModel(
          id: 'adh-test-1',
          uid: testUid,
          medicationId: 'med-test-1',
          medicationName: 'Test Medication',
          date: date,
          totalDoses: 2,
          takenDoses: 1,
          missedDoses: 1,
          lateDoses: 0,
          missedStreak: 1,
          adherenceScore: 50.0,
          createdAt: DateTime.now(),
        );

        expect(adherence.id, equals('adh-test-1'));
        expect(adherence.uid, equals(testUid));
        expect(adherence.medicationId, equals('med-test-1'));
        expect(adherence.totalDoses, equals(2));
        expect(adherence.takenDoses, equals(1));
        expect(adherence.missedDoses, equals(1));
        expect(adherence.missedStreak, equals(1));
        expect(adherence.adherenceScore, equals(50.0));
      });

      test('should convert to map and back', () {
        final original = MedicationAdherenceModel(
          id: 'adh-map-test',
          uid: testUid,
          medicationId: 'med-map-test',
          medicationName: 'Map Test Med',
          date: DateTime(2026, 5, 7),
          totalDoses: 3,
          takenDoses: 2,
          missedDoses: 1,
          lateDoses: 1,
          missedStreak: 0,
          adherenceScore: 66.67,
          createdAt: DateTime(2026, 5, 6),
        );

        final map = original.toMap();
        expect(map['id'], equals('adh-map-test'));
        expect(map['totalDoses'], equals(3));
        expect(map['takenDoses'], equals(2));
        expect(map['adherenceScore'], equals(66.67));
      });

      test('should parse status from adherence record', () {
        final adherences = [
          MedicationAdherenceModel(
            id: 'a1', uid: testUid, medicationId: 'm1', medicationName: 'M',
            date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
            lateDoses: 0, missedStreak: 0, adherenceScore: 95.0, createdAt: DateTime.now(),
          ),
          MedicationAdherenceModel(
            id: 'a2', uid: testUid, medicationId: 'm1', medicationName: 'M',
            date: DateTime.now(), totalDoses: 1, takenDoses: 1, missedDoses: 0,
            lateDoses: 0, missedStreak: 0, adherenceScore: 60.0, createdAt: DateTime.now(),
          ),
          MedicationAdherenceModel(
            id: 'a3', uid: testUid, medicationId: 'm1', medicationName: 'M',
            date: DateTime.now(), totalDoses: 1, takenDoses: 0, missedDoses: 1,
            lateDoses: 0, missedStreak: 1, adherenceScore: 0.0, createdAt: DateTime.now(),
          ),
        ];

        expect(adherences[0].getStatus(), equals('Excellent'));
        expect(adherences[1].getStatus(), equals('Fair'));
        expect(adherences[2].getStatus(), equals('Poor'));
      });

      test('should handle copyWith correctly', () {
        final original = MedicationAdherenceModel(
          id: 'orig', uid: testUid, medicationId: 'med1', medicationName: 'Med',
          date: DateTime(2026, 5, 7), totalDoses: 5, takenDoses: 3, missedDoses: 2,
          lateDoses: 0, missedStreak: 2, adherenceScore: 60.0, createdAt: DateTime.now(),
        );

        final updated = original.copyWith(
          adherenceScore: 80.0,
          takenDoses: 4,
          missedStreak: 0,
        );

        expect(updated.id, equals(original.id));
        expect(updated.adherenceScore, equals(80.0));
        expect(updated.takenDoses, equals(4));
        expect(updated.missedStreak, equals(0));
        expect(updated.totalDoses, equals(5)); // Unchanged
      });
    });

    // ==================== SCORING FORMULA VERIFICATION ====================
    group('Scoring Formula Verification', () {
      test('formula: (onTime + late*0.5) / total * 100', () {
        // Test various combinations
        expect(
          MedicationAdherenceModel.calculateScore(totalDoses: 1, takenDoses: 1, lateDoses: 0),
          equals(100.0),
        );

        expect(
          MedicationAdherenceModel.calculateScore(totalDoses: 2, takenDoses: 2, lateDoses: 2),
          equals(50.0),
        );

        expect(
          MedicationAdherenceModel.calculateScore(totalDoses: 4, takenDoses: 4, lateDoses: 2),
          equals(75.0),
        );

        expect(
          MedicationAdherenceModel.calculateScore(totalDoses: 10, takenDoses: 5, lateDoses: 0),
          equals(50.0),
        );
      });

      test('late doses contribute 50% credit', () {
        // With 2 total doses, both late = (0 + 2*0.5) / 2 * 100 = 50%
        final score1 = MedicationAdherenceModel.calculateScore(
          totalDoses: 2,
          takenDoses: 2,
          lateDoses: 2,
        );
        expect(score1, equals(50.0));

        // With 4 total doses, 1 on-time + 2 late = (1 + 2*0.5) / 4 * 100 = 50%
        final score2 = MedicationAdherenceModel.calculateScore(
          totalDoses: 4,
          takenDoses: 3,
          lateDoses: 2,
        );
        expect(score2, equals(50.0));
      });

      test('missed doses contribute 0% credit', () {
        // 1 on-time, 1 missed: (1 + 0*0.5) / 2 * 100 = 50%
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 2,
          takenDoses: 1,
          lateDoses: 0,
        );
        expect(score, equals(50.0));
      });
    });

    // ==================== EDGE CASES ====================
    group('Edge Cases', () {
      test('should handle negative or zero late doses gracefully', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 2,
          takenDoses: 0,
          lateDoses: 0,
        );
        expect(score, equals(0.0));
      });

      test('should handle perfect adherence across multiple days', () {
        final scores = [
          MedicationAdherenceModel.calculateScore(totalDoses: 3, takenDoses: 3, lateDoses: 0),
          MedicationAdherenceModel.calculateScore(totalDoses: 2, takenDoses: 2, lateDoses: 0),
          MedicationAdherenceModel.calculateScore(totalDoses: 4, takenDoses: 4, lateDoses: 0),
        ];

        for (final score in scores) {
          expect(score, equals(100.0));
        }
      });

      test('should handle mixed adherence patterns', () {
        final poor = MedicationAdherenceModel.calculateScore(
          totalDoses: 5,
          takenDoses: 0,
          lateDoses: 0,
        );
        expect(poor, equals(0.0));

        final fair = MedicationAdherenceModel.calculateScore(
          totalDoses: 5,
          takenDoses: 2,
          lateDoses: 0,
        );
        expect(fair, equals(40.0));

        final good = MedicationAdherenceModel.calculateScore(
          totalDoses: 5,
          takenDoses: 4,
          lateDoses: 0,
        );
        expect(good, equals(80.0));
      });

      test('should handle large dose counts', () {
        final score = MedicationAdherenceModel.calculateScore(
          totalDoses: 365,
          takenDoses: 350,
          lateDoses: 10,
        );

        // (350 - 10 + 10*0.5) / 365 * 100 = 345/365 * 100 ≈ 94.52
        expect(score, greaterThan(94.0));
        expect(score, lessThan(95.0));
      });
    });
  });
}
