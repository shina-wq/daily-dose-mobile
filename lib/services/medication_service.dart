import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../features/medications/models/medication_model.dart';
import '../features/medications/models/medication_dose_model.dart';
import '../features/medications/models/medication_adherence_model.dart';

class MedicationService {
  final FirebaseFirestore _firestore;

  MedicationService(this._firestore);

  static late MedicationService _instance;
  static const String _medicationsCollection = 'medications';
  static const String _dosesCollection = 'medication_doses';
  static const String _adherenceCollection = 'medication_adherence';

  // Factory constructor for production
  factory MedicationService.create() {
    return _instance;
  }

  // Static getter for backward compatibility
  static MedicationService get instance {
    _instance = MedicationService(FirebaseFirestore.instance);
    return _instance;
  }

  // For testing - allows injecting a mock Firestore
  static void setInstance(MedicationService service) {
    _instance = service;
  }

  // ==================== MEDICATION CRUD ====================

  /// Create a new medication
  Future<MedicationModel> createMedication(
    String uid,
    MedicationModel medication,
  ) async {
    try {
      final medicationId = const Uuid().v4();
      final newMedication = medication.copyWith(id: medicationId);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_medicationsCollection)
          .doc(medicationId)
          .set(newMedication.toMap());

      // Schedule initial doses for the medication
      await _scheduleInitialDoses(uid, newMedication);

      return newMedication;
    } catch (e) {
      throw Exception('Failed to create medication: $e');
    }
  }

  /// Get all medications for a user
  Future<List<MedicationModel>> getMedications(String uid) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_medicationsCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicationModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get medications: $e');
    }
  }

  /// Get active medications for a user
  Future<List<MedicationModel>> getActiveMedications(String uid) async {
    try {
      final now = DateTime.now();
      final allMedications = await getMedications(uid);

      return allMedications
          .where((med) {
            final isActive = med.isActive;
            final isAfterStart = med.startDate == null || now.isAfter(med.startDate!);
            final isBeforeEnd = med.endDate == null || now.isBefore(med.endDate!);
            return isActive && isAfterStart && isBeforeEnd;
          })
          .toList();
    } catch (e) {
      throw Exception('Failed to get active medications: $e');
    }
  }

  /// Get a specific medication
  Future<MedicationModel?> getMedicationById(String uid, String medicationId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_medicationsCollection)
          .doc(medicationId)
          .get();

      if (!doc.exists) return null;
      return MedicationModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get medication: $e');
    }
  }

  /// Update a medication
  Future<MedicationModel> updateMedication(
    String uid,
    MedicationModel medication,
  ) async {
    try {
      final existingMedication = await getMedicationById(uid, medication.id);
      final updatedMedication = medication.copyWith(updatedAt: DateTime.now());

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_medicationsCollection)
          .doc(medication.id)
          .update(updatedMedication.toMap());

      await _updateMedicationDoseMetadata(uid, updatedMedication);

      if (existingMedication != null && !_listEquals(existingMedication.timeSlots, updatedMedication.timeSlots)) {
        await _replaceUpcomingDoses(uid, updatedMedication);
      }

      return updatedMedication;
    } catch (e) {
      throw Exception('Failed to update medication: $e');
    }
  }

  /// Delete a medication
  Future<void> deleteMedication(String uid, String medicationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_medicationsCollection)
          .doc(medicationId)
          .delete();

      // Also delete associated doses and adherence records
      await _deleteMedicationDoses(uid, medicationId);
      await _deleteMedicationAdherence(uid, medicationId);
    } catch (e) {
      throw Exception('Failed to delete medication: $e');
    }
  }

  // ==================== DOSE SCHEDULING ====================

  /// Schedule initial doses when a medication is created
  Future<void> _scheduleInitialDoses(String uid, MedicationModel medication) async {
    try {
      final startDate = medication.startDate ?? DateTime.now();
      final endDate = medication.endDate ?? startDate.add(const Duration(days: 365));

      // Generate doses for the first 30 days
      final daysToSchedule = endDate.difference(startDate).inDays;
      final daysToCreate = daysToSchedule > 30 ? 30 : daysToSchedule;

      for (int i = 0; i < daysToCreate; i++) {
        final date = startDate.add(Duration(days: i));
        await _createDosesForDay(uid, medication, date);
      }
    } catch (e) {
      throw Exception('Failed to schedule initial doses: $e');
    }
  }

  /// Create dose records for a specific medication and day
  Future<void> _createDosesForDay(
    String uid,
    MedicationModel medication,
    DateTime date, {
    DateTime? onlyAfter,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final timeStr in medication.timeSlots) {
        final timeParts = timeStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );

        if (onlyAfter != null && !scheduledTime.isAfter(onlyAfter)) {
          continue;
        }

        final doseId = _doseDocumentId(medication.id, scheduledTime);
        final dose = MedicationDoseModel(
          id: doseId,
          uid: uid,
          medicationId: medication.id,
          medicationName: medication.name,
          dosage: medication.dosage,
          scheduledTime: scheduledTime,
          status: DoseStatus.pending,
          createdAt: DateTime.now(),
        );

        batch.set(
          _firestore
              .collection('users')
              .doc(uid)
              .collection(_dosesCollection)
              .doc(doseId),
          dose.toMap(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to create doses for day: $e');
    }
  }

  Future<void> _replaceUpcomingDoses(String uid, MedicationModel medication) async {
    try {
      final now = DateTime.now();
      final nowStr = now.toIso8601String();

      final futureDoses = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medication.id)
          .where('scheduledTime', isGreaterThanOrEqualTo: nowStr)
          .get();

      final batch = _firestore.batch();
      for (final doc in futureDoses.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      final today = DateTime(now.year, now.month, now.day);
      for (int i = 0; i < 30; i++) {
        final date = today.add(Duration(days: i));
        await _createDosesForDay(
          uid,
          medication,
          date,
          onlyAfter: i == 0 ? now : null,
        );
      }
    } catch (e) {
      throw Exception('Failed to replace upcoming doses: $e');
    }
  }

  Future<void> _updateMedicationDoseMetadata(String uid, MedicationModel medication) async {
    try {
      final doses = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medication.id)
          .get();

      final adherence = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_adherenceCollection)
          .where('medicationId', isEqualTo: medication.id)
          .get();

      final batch = _firestore.batch();
      for (final doc in doses.docs) {
        batch.update(doc.reference, {
          'medicationName': medication.name,
          'dosage': medication.dosage,
        });
      }

      for (final doc in adherence.docs) {
        batch.update(doc.reference, {
          'medicationName': medication.name,
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update medication dose metadata: $e');
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Schedule next 30 days of doses for a medication
  Future<void> scheduleNextDoses(String uid, String medicationId) async {
    try {
      final medication = await getMedicationById(uid, medicationId);
      if (medication == null) return;

      // Get the last scheduled dose
      final lastDoses = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medicationId)
          .orderBy('scheduledTime', descending: true)
          .limit(1)
          .get();

      DateTime nextScheduleDate;
      if (lastDoses.docs.isEmpty) {
        nextScheduleDate = DateTime.now();
      } else {
        final lastDose = MedicationDoseModel.fromMap(lastDoses.docs.first.data());
        nextScheduleDate = lastDose.scheduledTime.add(const Duration(days: 1));
      }

      // Schedule next 30 days
      final endDate = medication.endDate ?? nextScheduleDate.add(const Duration(days: 365));
      final daysToSchedule = endDate.difference(nextScheduleDate).inDays;
      final daysToCreate = daysToSchedule > 30 ? 30 : daysToSchedule;

      for (int i = 0; i < daysToCreate; i++) {
        final date = nextScheduleDate.add(Duration(days: i));
        await _createDosesForDay(uid, medication, date);
      }
    } catch (e) {
      throw Exception('Failed to schedule next doses: $e');
    }
  }

  // ==================== DOSE TRACKING ====================

  /// Mark a dose as taken
  Future<void> markDoseTaken(String uid, String doseId) async {
    try {
      final now = DateTime.now();
      final dose = await getDoseById(uid, doseId);
      if (dose == null) return;

      final updatedDose = dose.copyWith(
        takenTime: now,
        status: dose.isLate() ? DoseStatus.late : DoseStatus.taken,
      );

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .doc(doseId)
          .update(updatedDose.toMap());

      // Update adherence records
      await _updateAdherence(uid, dose.medicationId, dose.scheduledTime.toDateOnly());
    } catch (e) {
      throw Exception('Failed to mark dose taken: $e');
    }
  }

  /// Mark a dose as missed
  Future<void> markDoseMissed(String uid, String doseId) async {
    try {
      final dose = await getDoseById(uid, doseId);
      if (dose == null) return;

      final updatedDose = dose.copyWith(status: DoseStatus.missed);

      await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .doc(doseId)
          .update(updatedDose.toMap());

      // Update adherence records
      await _updateAdherence(uid, dose.medicationId, dose.scheduledTime.toDateOnly());
    } catch (e) {
      throw Exception('Failed to mark dose missed: $e');
    }
  }

  /// Get all doses for a medication
  Future<List<MedicationDoseModel>> getMedicationDoses(
    String uid,
    String medicationId,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medicationId)
          .orderBy('scheduledTime', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .whereType<MedicationDoseModel>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get medication doses: $e');
    }
  }

  /// Get doses for a specific date
  Future<List<MedicationDoseModel>> getDosesForDate(String uid, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
    // Use ISO8601 strings for Firestore comparison
    final startOfDayStr = startOfDay.toIso8601String();
    final endOfDayStr = endOfDay.toIso8601String();

    final snapshot = await _firestore
      .collection('users')
      .doc(uid)
      .collection(_dosesCollection)
      .where('scheduledTime', isGreaterThanOrEqualTo: startOfDayStr)
      .where('scheduledTime', isLessThan: endOfDayStr)
          .orderBy('scheduledTime')
          .get();

      return snapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .whereType<MedicationDoseModel>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get doses for date: $e');
    }
  }

  /// Mark any pending doses that are already past due as missed.
  Future<int> finalizeOverdueDoses(String uid) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('status', isEqualTo: DoseStatus.pending.toString().split('.').last)
          .where('scheduledTime', isLessThan: now.toIso8601String())
          .orderBy('scheduledTime')
          .get();

      if (snapshot.docs.isEmpty) return 0;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': DoseStatus.missed.toString().split('.').last,
        });
      }
      await batch.commit();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to finalize overdue doses: $e');
    }
  }

  /// Get doses between two datetimes (start inclusive, end exclusive)
  Future<List<MedicationDoseModel>> getDosesBetween(
    String uid,
    DateTime startInclusive,
    DateTime endExclusive,
  ) async {
    try {
      final startStr = startInclusive.toIso8601String();
      final endStr = endExclusive.toIso8601String();

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('scheduledTime', isGreaterThanOrEqualTo: startStr)
          .where('scheduledTime', isLessThan: endStr)
          .orderBy('scheduledTime')
          .get();

      return snapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .whereType<MedicationDoseModel>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get doses between dates: $e');
    }
  }

  /// Get a specific dose
  Future<MedicationDoseModel?> getDoseById(String uid, String doseId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .doc(doseId)
          .get();

      if (!doc.exists) return null;
      return MedicationDoseModel.fromMap(doc.data()!);
    } catch (e) {
      throw Exception('Failed to get dose: $e');
    }
  }

  /// Get pending doses (not yet taken and scheduled in the past or present)
  Future<List<MedicationDoseModel>> getPendingDoses(String uid) async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('status', isEqualTo: DoseStatus.pending.toString().split('.').last)
          .where('scheduledTime', isLessThanOrEqualTo: now)
          .orderBy('scheduledTime')
          .get();

      return snapshot.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .whereType<MedicationDoseModel>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get pending doses: $e');
    }
  }

  // ==================== ADHERENCE TRACKING ====================

  /// Calculate and update adherence for a specific medication and date
  Future<void> _updateAdherence(String uid, String medicationId, DateTime date) async {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      final startOfDayStr = startOfDay.toIso8601String();
      final endOfDayStr = endOfDay.toIso8601String();

    try {
      final doses = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medicationId)
            .where('scheduledTime', isGreaterThanOrEqualTo: startOfDayStr)
            .where('scheduledTime', isLessThan: endOfDayStr)
          .get();

      if (doses.docs.isEmpty) return;

      final doseList = doses.docs
          .map((doc) => MedicationDoseModel.fromMap(doc.data()))
          .whereType<MedicationDoseModel>()
          .toList();

      int totalDoses = doseList.length;
      int takenDoses = doseList.where((d) => d.status == DoseStatus.taken).length;
      int lateDoses = doseList.where((d) => d.status == DoseStatus.late).length;
      int missedDoses = doseList.where((d) => d.status == DoseStatus.missed).length;

      // Calculate missed streak
      int missedStreak = 0;
      DateTime checkDate = date;
      while (checkDate.isAfter(date.subtract(const Duration(days: 365)))) {
          final checkStartDay = DateTime(checkDate.year, checkDate.month, checkDate.day);
          final checkEndDay = checkStartDay.add(const Duration(days: 1));
          final checkStartDayStr = checkStartDay.toIso8601String();
          final checkEndDayStr = checkEndDay.toIso8601String();
        
        final checkDoses = await _firestore
            .collection('users')
            .doc(uid)
            .collection(_dosesCollection)
            .where('medicationId', isEqualTo: medicationId)
            .where('scheduledTime', isGreaterThanOrEqualTo: checkStartDayStr)
            .where('scheduledTime', isLessThan: checkEndDayStr)
            .get();

        if (checkDoses.docs.isEmpty) break;

        final dayDoses = checkDoses.docs
            .map((doc) => MedicationDoseModel.fromMap(doc.data()))
            .whereType<MedicationDoseModel>()
            .toList();
        final allMissed = dayDoses.every((d) => d.status == DoseStatus.missed);

        if (allMissed) {
          missedStreak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      final score = MedicationAdherenceModel.calculateScore(
        totalDoses: totalDoses,
        takenDoses: takenDoses,
        lateDoses: lateDoses,
      );

      final adherenceId = const Uuid().v4();
      final adherence = MedicationAdherenceModel(
        id: adherenceId,
        uid: uid,
        medicationId: medicationId,
        medicationName: doseList.first.medicationName,
        date: date,
        totalDoses: totalDoses,
        takenDoses: takenDoses,
        missedDoses: missedDoses,
        lateDoses: lateDoses,
        missedStreak: missedStreak,
        adherenceScore: score,
        createdAt: DateTime.now(),
      );

      // Check if adherence record already exists for this day
      final existing = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_adherenceCollection)
          .where('medicationId', isEqualTo: medicationId)
            .where('date', isGreaterThanOrEqualTo: startOfDayStr)
            .where('date', isLessThan: endOfDayStr)
          .get();

      if (existing.docs.isNotEmpty) {
        // Update existing adherence record
        await _firestore
            .collection('users')
            .doc(uid)
            .collection(_adherenceCollection)
            .doc(existing.docs.first.id)
            .update(adherence.toMap());
      } else {
        // Create new adherence record
        await _firestore
            .collection('users')
            .doc(uid)
            .collection(_adherenceCollection)
            .doc(adherenceId)
            .set(adherence.toMap());
      }
    } catch (e, st) {
      // Don't let adherence calculation failures block dose actions (e.g. missing Firestore index)
      // Log for debugging but swallow the error so caller operations (mark taken/missed) succeed.
      // ignore: avoid_print
      print('Warning: Failed to update adherence: $e\n$st');
      return;
    }
  }

  /// Get adherence records for a medication
  Future<List<MedicationAdherenceModel>> getAdherence(
    String uid,
    String medicationId, {
    int days = 30,
  }) async {
    try {
      final fromDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_adherenceCollection)
          .where('medicationId', isEqualTo: medicationId)
          .where('date', isGreaterThanOrEqualTo: fromDate)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MedicationAdherenceModel.fromMap(doc.data()))
          .whereType<MedicationAdherenceModel>()
          .toList();
    } catch (e) {
      throw Exception('Failed to get adherence records: $e');
    }
  }

  /// Get overall adherence score for a user across all medications
  Future<double> getOverallAdherence(String uid, {int days = 30}) async {
    try {
      final fromDate = DateTime.now().subtract(Duration(days: days));

      final snapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_adherenceCollection)
          .where('date', isGreaterThanOrEqualTo: fromDate)
          .get();

      if (snapshot.docs.isEmpty) return 100.0;

      double totalScore = 0;
      for (final doc in snapshot.docs) {
        final adherence = MedicationAdherenceModel.fromMap(doc.data());
        totalScore += adherence.adherenceScore;
      }

      return totalScore / snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get overall adherence: $e');
    }
  }

  // ==================== HELPER METHODS ====================

  Future<void> _deleteMedicationDoses(String uid, String medicationId) async {
    try {
      final doses = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_dosesCollection)
          .where('medicationId', isEqualTo: medicationId)
          .get();

      final batch = _firestore.batch();
      for (final doc in doses.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete medication doses: $e');
    }
  }

  Future<void> _deleteMedicationAdherence(String uid, String medicationId) async {
    try {
      final adherence = await _firestore
          .collection('users')
          .doc(uid)
          .collection(_adherenceCollection)
          .where('medicationId', isEqualTo: medicationId)
          .get();

      final batch = _firestore.batch();
      for (final doc in adherence.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete medication adherence: $e');
    }
  }

  String _doseDocumentId(String medicationId, DateTime scheduledTime) {
    final stamp =
        '${scheduledTime.year.toString().padLeft(4, '0')}${scheduledTime.month.toString().padLeft(2, '0')}${scheduledTime.day.toString().padLeft(2, '0')}_'
        '${scheduledTime.hour.toString().padLeft(2, '0')}${scheduledTime.minute.toString().padLeft(2, '0')}';
    return '${medicationId}_$stamp';
  }
}

/// Extension to convert DateTime to date-only format
extension DateOnlyComparison on DateTime {
  DateTime toDateOnly() {
    return DateTime(year, month, day);
  }
}
