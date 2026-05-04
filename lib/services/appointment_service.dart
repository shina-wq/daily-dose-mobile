import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/appointments/models/appointment_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class AppointmentService {
	AppointmentService._();

	static final AppointmentService instance = AppointmentService._();

	final AuthService _authService = AuthService.instance;
	final FirestoreService _firestoreService = FirestoreService.instance;

	String _requireUid(String? uid) {
		final resolvedUid = uid ?? _authService.currentUser?.uid;
		if (resolvedUid == null) {
			throw StateError('No authenticated user found.');
		}

		return resolvedUid;
	}

	CollectionReference<Map<String, dynamic>> _collection(String uid) {
		return _firestoreService.appointmentsForUser(uid);
	}

	Stream<List<AppointmentModel>> watchAppointments({String? uid}) {
		final resolvedUid = _requireUid(uid);
		return _collection(resolvedUid)
				.orderBy('appointmentDateTime')
				.snapshots()
				.map(
					(snapshot) => snapshot.docs
							.map((doc) => AppointmentModel.fromMap(doc.data(), doc.id))
							.toList(),
				);
	}

	Future<AppointmentModel> saveAppointment({
		String? uid,
		required AppointmentModel appointment,
	}) async {
		final resolvedUid = _requireUid(uid);
		final now = DateTime.now().toUtc();
		final docRef = appointment.id.isEmpty
				? _collection(resolvedUid).doc()
				: _collection(resolvedUid).doc(appointment.id);
		final payload = appointment.copyWith(
			id: docRef.id,
			updatedAt: now,
			createdAt: appointment.createdAt,
		);

		await docRef.set(
			payload.toMap(),
			SetOptions(merge: true),
		);

		return payload;
	}

	Future<void> completeAppointment({
		String? uid,
		required String appointmentId,
		required String completionNotes,
	}) async {
		final resolvedUid = _requireUid(uid);
		final docRef = _collection(resolvedUid).doc(appointmentId);
		await docRef.update({
			'status': 'completed',
			'completionNotes': completionNotes,
			'completedAt': Timestamp.fromDate(DateTime.now().toUtc()),
			'updatedAt': Timestamp.fromDate(DateTime.now().toUtc()),
		});
	}

	Future<void> deleteAppointment({
		String? uid,
		required String appointmentId,
	}) async {
		final resolvedUid = _requireUid(uid);
		await _collection(resolvedUid).doc(appointmentId).delete();
	}
}
