import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/health_log/models/health_log_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class HealthLogService {
	HealthLogService._();

	static final HealthLogService instance = HealthLogService._();

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
		return _firestoreService.healthLogsForUser(uid);
	}

	Stream<List<HealthLogModel>> watchHealthLogs({String? uid}) {
		final resolvedUid = _requireUid(uid);
		return _collection(resolvedUid)
				.orderBy('loggedAt', descending: true)
				.snapshots()
				.map(
					(snapshot) => snapshot.docs
							.map((doc) => HealthLogModel.fromMap(doc.data(), doc.id))
							.toList(),
				);
	}

	Stream<List<HealthLogModel>> watchSymptomHistory({
		String? uid,
		required String symptom,
		int limit = 10,
	}) {
		final resolvedUid = _requireUid(uid);
		return _collection(resolvedUid)
				.where('symptom', isEqualTo: symptom)
				.orderBy('loggedAt', descending: true)
				.limit(limit)
				.snapshots()
				.map(
					(snapshot) => snapshot.docs
							.map((doc) => HealthLogModel.fromMap(doc.data(), doc.id))
							.toList(),
				);
	}

	Future<HealthLogModel> saveHealthLog({
		String? uid,
		required HealthLogModel healthLog,
	}) async {
		final resolvedUid = _requireUid(uid);
		final now = DateTime.now().toUtc();
		final docRef = healthLog.id.isEmpty
				? _collection(resolvedUid).doc()
				: _collection(resolvedUid).doc(healthLog.id);
		final payload = healthLog.copyWith(
			id: docRef.id,
			updatedAt: now,
			createdAt: healthLog.createdAt,
		);

		await docRef.set(
			payload.toMap(),
			SetOptions(merge: true),
		);

		return payload;
	}

	Future<void> deleteHealthLog({
		String? uid,
		required String healthLogId,
	}) async {
		final resolvedUid = _requireUid(uid);
		await _collection(resolvedUid).doc(healthLogId).delete();
	}
}
