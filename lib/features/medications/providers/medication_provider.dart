import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/medication_service.dart';
import '../models/medication_model.dart';
import '../models/medication_dose_model.dart';
import '../models/medication_adherence_model.dart';
import '../../../core/providers/auth_provider.dart';

/// Provider for the medication service
final medicationServiceProvider = Provider<MedicationService>((ref) => MedicationService.instance);

/// Fetch all medications for the authenticated user
final medicationsProvider = FutureProvider.autoDispose<List<MedicationModel>>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getMedications(uid);
});

/// Active medications
final activeMedicationsProvider = FutureProvider.autoDispose<List<MedicationModel>>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getActiveMedications(uid);
});

/// Single medication by id
final medicationByIdProvider = FutureProvider.autoDispose.family<MedicationModel?, String>((ref, medicationId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return null;
  final service = ref.watch(medicationServiceProvider);
  return service.getMedicationById(uid, medicationId);
});

/// Doses for a given date
final dosesForDateProvider = FutureProvider.autoDispose.family<List<MedicationDoseModel>, DateTime>((ref, date) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getDosesForDate(uid, date);
});

/// Today's doses
final todaysDosesProvider = FutureProvider.autoDispose<List<MedicationDoseModel>>((ref) async {
  final today = DateTime.now();
  return ref.watch(dosesForDateProvider(today).future);
});

/// Pending doses
final pendingDosesProvider = FutureProvider.autoDispose<List<MedicationDoseModel>>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getPendingDoses(uid);
});

/// Doses for a medication
final medicationDosesProvider = FutureProvider.autoDispose.family<List<MedicationDoseModel>, String>((ref, medicationId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getMedicationDoses(uid, medicationId);
});

/// Single dose by id
final doseByIdProvider = FutureProvider.autoDispose.family<MedicationDoseModel?, String>((ref, doseId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return null;
  final service = ref.watch(medicationServiceProvider);
  return service.getDoseById(uid, doseId);
});

/// Adherence records for a medication
final adherenceProvider = FutureProvider.autoDispose.family<List<MedicationAdherenceModel>, String>((ref, medicationId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return [];
  final service = ref.watch(medicationServiceProvider);
  return service.getAdherence(uid, medicationId, days: 30);
});

/// Overall adherence
final overallAdherenceProvider = FutureProvider.autoDispose<double>((ref) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) return 0.0;
  final service = ref.watch(medicationServiceProvider);
  return service.getOverallAdherence(uid, days: 30);
});

// ------------------ Simple action providers ------------------

/// Form state for medication create/update (simple holder)
class MedicationFormState {
  final bool isLoading;
  final String? error;
  final MedicationModel? medication;

  const MedicationFormState({this.isLoading = false, this.error, this.medication});

  MedicationFormState copyWith({bool? isLoading, String? error, MedicationModel? medication}) {
    return MedicationFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      medication: medication ?? this.medication,
    );
  }
}

/// Action providers for create/update/delete
final createMedicationProvider = FutureProvider.family.autoDispose<void, MedicationModel>((ref, medication) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final service = ref.watch(medicationServiceProvider);
  await service.createMedication(uid, medication);
});

final updateMedicationProvider = FutureProvider.family.autoDispose<void, MedicationModel>((ref, medication) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final service = ref.watch(medicationServiceProvider);
  await service.updateMedication(uid, medication);
});

final deleteMedicationProvider = FutureProvider.family.autoDispose<void, String>((ref, medicationId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final service = ref.watch(medicationServiceProvider);
  await service.deleteMedication(uid, medicationId);
});

/// Dose action providers
final markDoseTakenProvider = FutureProvider.family.autoDispose<void, String>((ref, doseId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final service = ref.watch(medicationServiceProvider);
  await service.markDoseTaken(uid, doseId);
});

final markDoseMissedProvider = FutureProvider.family.autoDispose<void, String>((ref, doseId) async {
  final auth = ref.watch(authStateProvider);
  final uid = auth.asData?.value?.uid;
  if (uid == null) throw Exception('Not authenticated');
  final service = ref.watch(medicationServiceProvider);
  await service.markDoseMissed(uid, doseId);
});

