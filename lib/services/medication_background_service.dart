import 'medication_service.dart';
import '../features/medications/models/medication_dose_model.dart';
import '../features/medications/models/medication_adherence_model.dart';
import 'notification_service.dart';

/// Service to handle background medication tasks
/// Schedules reminders, checks for missed doses, and calculates adherence
class MedicationBackgroundService {
	MedicationBackgroundService._();
	static final MedicationBackgroundService instance = MedicationBackgroundService._();

	final MedicationService _medicationService = MedicationService.instance;
	final NotificationService _notificationService = NotificationService.instance;

	/// Initialize daily medication tasks for a user
	/// Call this when user logs in or app starts
	Future<void> initializeDailyTasks(String uid) async {
		try {
			// Schedule reminders for today's pending doses
			await _scheduleRemindersForToday(uid);

			// Check for missed doses from yesterday
			await _checkAndNotifyMissedDoses(uid);

			// Check for missed dose streaks
			await _checkMissedStreaks(uid);

			// Send daily adherence report
			await _sendDailyAdherenceReport(uid);

			// Schedule next batch of doses if needed
			await _scheduleNextBatchOfDoses(uid);
		} catch (e) {
			print('Error initializing daily tasks: $e');
		}
	}

	/// Schedule all reminders for today's doses
	Future<void> _scheduleRemindersForToday(String uid) async {
		try {
			final today = DateTime.now();
			final doses = await _medicationService.getDosesForDate(uid, today);

			// Only schedule reminders for pending doses in the future
			final now = DateTime.now();
			for (final dose in doses) {
				if (dose.status == DoseStatus.pending && dose.scheduledTime.isAfter(now)) {
					await _notificationService.scheduleMedicationReminder(uid, dose);
				}
			}
		} catch (e) {
			print('Error scheduling reminders: $e');
		}
	}

	/// Check for doses that were missed and send notifications
	Future<void> _checkAndNotifyMissedDoses(String uid) async {
		try {
			final yesterday = DateTime.now().subtract(const Duration(days: 1));
			final doses = await _medicationService.getDosesForDate(uid, yesterday);

			for (final dose in doses) {
				// If a dose is still pending, it's missed (it's now the next day)
				if (dose.status == DoseStatus.pending) {
					await _medicationService.markDoseMissed(uid, dose.id);
					await _notificationService.notifyMissedDose(uid, dose);
				}
			}
		} catch (e) {
			print('Error checking missed doses: $e');
		}
	}

	/// Check for consecutive missed doses and send streak warnings
	Future<void> _checkMissedStreaks(String uid) async {
		try {
			// Get all medications
			final medications = await _medicationService.getActiveMedications(uid);

			for (final medication in medications) {
				// Get recent adherence records
				final adherence = await _medicationService.getAdherence(
					uid,
					medication.id,
					days: 30,
				);

				if (adherence.isNotEmpty) {
					final latestAdherence = adherence.first;

					// Notify if there's a streak of 2 or more days
					if (latestAdherence.missedStreak >= 2) {
						await _notificationService.notifyMissedDoseStreak(
							uid,
							medication.name,
							latestAdherence.missedStreak,
						);
					}
				}
			}
		} catch (e) {
			print('Error checking missed streaks: $e');
		}
	}

	/// Send daily adherence report
	Future<void> _sendDailyAdherenceReport(String uid) async {
		try {
			final today = DateTime.now();
			final doses = await _medicationService.getDosesForDate(uid, today);

			if (doses.isEmpty) return;

			int totalDoses = doses.length;
			int takenDoses = doses.where((d) => d.status == DoseStatus.taken).length;
			int lateDoses = doses.where((d) => d.status == DoseStatus.late).length;
			int missedDoses = doses.where((d) => d.status == DoseStatus.missed).length;

			final score = MedicationAdherenceModel.calculateScore(
				totalDoses: totalDoses,
				takenDoses: takenDoses,
				lateDoses: lateDoses,
			);

			// Only send report if there's at least one dose taken or missed
			if (takenDoses > 0 || missedDoses > 0) {
				await _notificationService.sendDailyAdherenceReport(
					uid,
					score,
					totalDoses,
					takenDoses,
					missedDoses,
				);
			}
		} catch (e) {
			print('Error sending adherence report: $e');
		}
	}

	/// Schedule the next batch of doses (next 30 days)
	Future<void> _scheduleNextBatchOfDoses(String uid) async {
		try {
			final medications = await _medicationService.getActiveMedications(uid);

			for (final medication in medications) {
				await _medicationService.scheduleNextDoses(uid, medication.id);
			}
		} catch (e) {
			print('Error scheduling next doses: $e');
		}
	}

	/// Get daily summary for today's medications
	Future<Map<String, dynamic>> getDailySummary(String uid) async {
		try {
			final today = DateTime.now();
			final doses = await _medicationService.getDosesForDate(uid, today);

			final total = doses.length;
			final taken = doses.where((d) => d.status == DoseStatus.taken).length;
			final late = doses.where((d) => d.status == DoseStatus.late).length;
			final missed = doses.where((d) => d.status == DoseStatus.missed).length;
			final pending = doses.where((d) => d.status == DoseStatus.pending).length;

			final score = MedicationAdherenceModel.calculateScore(
				totalDoses: total,
				takenDoses: taken,
				lateDoses: late,
			);

			return {
				'total': total,
				'taken': taken,
				'late': late,
				'missed': missed,
				'pending': pending,
				'score': score,
				'status': _getAdherenceStatus(score),
			};
		} catch (e) {
			return {
				'error': e.toString(),
			};
		}
	}

	String _getAdherenceStatus(double score) {
		if (score >= 90) return 'Excellent';
		if (score >= 75) return 'Good';
		if (score >= 50) return 'Fair';
		return 'Poor';
	}

	/// Get upcoming doses for the next 24 hours
	Future<List<MedicationDoseModel>> getUpcomingDoses(String uid) async {
		try {
			final now = DateTime.now();
			final tomorrow = now.add(const Duration(days: 1));

			// Get today's doses and filter for ones after now
			final todaysDoses = await _medicationService.getDosesForDate(uid, now);
			return todaysDoses
				.where((dose) => dose.scheduledTime.isAfter(now) && dose.scheduledTime.isBefore(tomorrow))
				.toList();
		} catch (e) {
			return [];
		}
	}

	/// Manual task to manually check and update adherence for all medications
	Future<void> recalculateAllAdherence(String uid) async {
		try {
			final medications = await _medicationService.getActiveMedications(uid);

			for (final medication in medications) {
				// Update adherence for today
				await _medicationService.getAdherence(uid, medication.id, days: 1);
			}
		} catch (e) {
			print('Error recalculating adherence: $e');
		}
	}
}
