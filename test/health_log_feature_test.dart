import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_dose_mobile/features/health_log/models/health_log_model.dart';
import 'package:daily_dose_mobile/services/health_log_service.dart';
import 'package:daily_dose_mobile/services/auth_service.dart';
import 'package:daily_dose_mobile/services/firestore_service.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Health Log Feature Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late _TestFirestoreService firestoreService;
    late _TestHealthLogService healthLogService;
    late _MockAuthService mockAuthService;

    const String testUserId = 'test-user-health-log';

    setUp(() {
      // Initialize fake Firestore
      fakeFirestore = FakeFirebaseFirestore();
      
      // Setup custom Firestore service for testing
      firestoreService = _TestFirestoreService(fakeFirestore);
      FirestoreService.setInstanceForTesting(firestoreService);
      
      // Setup mock auth service - inject by setting the instance directly
      mockAuthService = _MockAuthService(testUserId);
      AuthService.instance = mockAuthService;
      
      // Create a test instance of HealthLogService with our mocked dependencies
      healthLogService = _TestHealthLogService(mockAuthService, firestoreService);
    });

    // ==================== SYMPTOM LOGGING TESTS ====================
    group('Logging Symptoms', () {
      test('User can log a symptom entry', () async {
        final now = DateTime.now();
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Moderate',
          loggedAt: now,
          notes: 'Felt tired after lunch',
          triggers: ['Poor Sleep', 'Physical Activity'],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        expect(savedLog.id.isNotEmpty, true);
        expect(savedLog.symptom, equals('Fatigue'));
        expect(savedLog.severity, equals('Moderate'));
        expect(savedLog.notes, equals('Felt tired after lunch'));
        expect(savedLog.triggers, equals(['Poor Sleep', 'Physical Activity']));
      });

      test('User can log different symptom types', () async {
        final symptoms = ['Fatigue', 'Headache', 'Nausea', 'Dizziness'];
        final now = DateTime.now();

        for (final symptom in symptoms) {
          final logEntry = HealthLogModel(
            id: '',
            symptom: symptom,
            severity: 'Mild',
            loggedAt: now,
            notes: 'Test $symptom',
            triggers: [],
            createdAt: now,
            updatedAt: now,
          );

          final savedLog = await healthLogService.saveHealthLog(
            uid: testUserId,
            healthLog: logEntry,
          );

          expect(savedLog.symptom, equals(symptom));
        }
      });

      test('User can log symptom with all severity levels', () async {
        final severityLevels = ['Mild', 'Moderate', 'Severe', 'Extreme'];
        final now = DateTime.now();

        for (final severity in severityLevels) {
          final logEntry = HealthLogModel(
            id: '',
            symptom: 'Headache',
            severity: severity,
            loggedAt: now,
            notes: 'Severity test',
            triggers: [],
            createdAt: now,
            updatedAt: now,
          );

          final savedLog = await healthLogService.saveHealthLog(
            uid: testUserId,
            healthLog: logEntry,
          );

          expect(savedLog.severity, equals(severity));
        }
      });

      test('User can log symptom with optional triggers', () async {
        final now = DateTime.now();
        final triggers = ['Poor Sleep', 'Stress', 'Missed Meal', 'Dehydration'];
        
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Nausea',
          severity: 'Severe',
          loggedAt: now,
          notes: 'Experiencing nausea',
          triggers: triggers,
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        expect(savedLog.triggers.length, equals(4));
        expect(savedLog.triggers, equals(triggers));
      });

      test('User can log symptom with optional notes', () async {
        final now = DateTime.now();
        final notes =
            'Felt unusually tired after lunch. Didn\'t sleep well last night.';
        
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Moderate',
          loggedAt: now,
          notes: notes,
          triggers: [],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        expect(savedLog.notes, equals(notes));
      });
    });

    // ==================== ENTRY STORAGE & RETRIEVAL TESTS ====================
    group('Entry Storage and Retrieval', () {
      test('Saved entries persist in Firestore', () async {
        final now = DateTime.now();
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Moderate',
          loggedAt: now,
          notes: 'Persistence test',
          triggers: ['Stress'],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        // Retrieve the entry
        final docRef = fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('health_logs')
            .doc(savedLog.id);
        
        final doc = await docRef.get();
        expect(doc.exists, true);
        
        final retrievedData = doc.data() as Map<String, dynamic>;
        expect(retrievedData['symptom'], equals('Headache'));
        expect(retrievedData['severity'], equals('Moderate'));
      });

      test('Multiple entries are saved independently', () async {
        final now = DateTime.now();
        
        // Save first entry
        final log1 = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: now,
          notes: 'Entry 1',
          triggers: [],
          createdAt: now,
          updatedAt: now,
        );
        
        // Save second entry
        final log2 = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Severe',
          loggedAt: now.add(const Duration(hours: 2)),
          notes: 'Entry 2',
          triggers: ['Stress'],
          createdAt: now.add(const Duration(hours: 2)),
          updatedAt: now.add(const Duration(hours: 2)),
        );

        final savedLog1 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log1,
        );
        
        final savedLog2 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log2,
        );

        expect(savedLog1.id, isNotEmpty);
        expect(savedLog2.id, isNotEmpty);
        expect(savedLog1.id, isNot(equals(savedLog2.id)));
      });

      test('Entry data is correctly serialized to Firestore', () async {
        final now = DateTime.now();
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Dizziness',
          severity: 'Extreme',
          loggedAt: now,
          notes: 'Serialization test',
          triggers: ['Weather', 'Physical Activity'],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        // Verify serialization
        final docRef = fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('health_logs')
            .doc(savedLog.id);
        
        final doc = await docRef.get();
        final data = doc.data() as Map<String, dynamic>;

        expect(data['id'], isNotEmpty);
        expect(data['symptom'], isNotEmpty);
        expect(data['severity'], isNotEmpty);
        expect(data['loggedAt'], isNotNull);
        expect(data['notes'], isNotNull);
        expect(data['triggers'], isList);
      });
    });

    // ==================== DAILY LOGGING TESTS ====================
    group('Daily Logging Behavior', () {
      test('User can log multiple entries on the same day', () async {
        final baseDate = DateTime(2024, 5, 8, 8, 0); // May 8, 8:00 AM
        
        // First entry - 8:00 AM
        final log1 = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: baseDate,
          notes: 'Morning',
          triggers: [],
          createdAt: baseDate,
          updatedAt: baseDate,
        );

        // Second entry - 12:30 PM same day
        final log2 = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Moderate',
          loggedAt: baseDate.add(const Duration(hours: 4, minutes: 30)),
          notes: 'Afternoon',
          triggers: ['Stress'],
          createdAt: baseDate.add(const Duration(hours: 4, minutes: 30)),
          updatedAt: baseDate.add(const Duration(hours: 4, minutes: 30)),
        );

        final savedLog1 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log1,
        );
        
        final savedLog2 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log2,
        );

        // Verify both entries exist
        expect(savedLog1.id, isNotEmpty);
        expect(savedLog2.id, isNotEmpty);
        expect(savedLog1.id, isNot(equals(savedLog2.id)));
        
        // Verify they have different symptoms (no overwrite)
        expect(savedLog1.symptom, equals('Fatigue'));
        expect(savedLog2.symptom, equals('Headache'));
      });

      test('Daily logging does not overwrite previous entries', () async {
        final date1 = DateTime(2024, 5, 8, 8, 0);
        
        // First entry
        final log1 = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: date1,
          notes: 'First log',
          triggers: [],
          createdAt: date1,
          updatedAt: date1,
        );

        final savedLog1 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log1,
        );

        // Second entry later same day
        final log2 = HealthLogModel(
          id: '',
          symptom: 'Nausea',
          severity: 'Severe',
          loggedAt: date1.add(const Duration(hours: 6)),
          notes: 'Second log',
          triggers: ['Dehydration'],
          createdAt: date1.add(const Duration(hours: 6)),
          updatedAt: date1.add(const Duration(hours: 6)),
        );

        final savedLog2 = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: log2,
        );

        // Verify first entry is not overwritten
        final docRef1 = fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('health_logs')
            .doc(savedLog1.id);
        
        final doc1 = await docRef1.get();
        final data1 = doc1.data() as Map<String, dynamic>;
        
        expect(data1['symptom'], equals('Fatigue'));
        expect(data1['notes'], equals('First log'));
      });

      test('User can edit a previous entry without creating duplicates', () async {
        final now = DateTime.now();
        
        // Create initial entry
        final initialLog = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Mild',
          loggedAt: now,
          notes: 'Initial notes',
          triggers: [],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: initialLog,
        );

        // Edit the entry (same ID)
        final editedLog = savedLog.copyWith(
          severity: 'Severe',
          notes: 'Updated notes',
          triggers: ['Stress'],
          updatedAt: now.add(const Duration(hours: 1)),
        );

        final updatedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: editedLog,
        );

        // Verify no duplicate entries created
        final collectionRef = fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('health_logs');
        
        final snapshot = await collectionRef.get();
        expect(snapshot.docs.length, equals(1));

        // Verify the entry was updated
        expect(updatedLog.severity, equals('Severe'));
        expect(updatedLog.notes, equals('Updated notes'));
        expect(updatedLog.triggers, equals(['Stress']));
      });
    });

    // ==================== ENTRY DISPLAY TESTS ====================
    group('Entry Display on Health Log Page', () {
      test('Health log entries are ordered by most recent first', () async {
        final baseDate = DateTime(2024, 5, 8);
        
        // Create entries on different dates
        final log1 = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: baseDate,
          notes: 'Day 1',
          triggers: [],
          createdAt: baseDate,
          updatedAt: baseDate,
        );

        final log2 = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Moderate',
          loggedAt: baseDate.add(const Duration(days: 1)),
          notes: 'Day 2',
          triggers: [],
          createdAt: baseDate.add(const Duration(days: 1)),
          updatedAt: baseDate.add(const Duration(days: 1)),
        );

        final log3 = HealthLogModel(
          id: '',
          symptom: 'Nausea',
          severity: 'Severe',
          loggedAt: baseDate.add(const Duration(days: 2)),
          notes: 'Day 3',
          triggers: [],
          createdAt: baseDate.add(const Duration(days: 2)),
          updatedAt: baseDate.add(const Duration(days: 2)),
        );

        // Save in non-chronological order
        await healthLogService.saveHealthLog(uid: testUserId, healthLog: log1);
        await healthLogService.saveHealthLog(uid: testUserId, healthLog: log3);
        await healthLogService.saveHealthLog(uid: testUserId, healthLog: log2);

        // Get all entries via stream
        final logs = await healthLogService.watchHealthLogs().first;

        // Verify ordering (most recent first)
        expect(logs.length, equals(3));
        expect(logs[0].notes, equals('Day 3')); // Most recent
        expect(logs[1].notes, equals('Day 2'));
        expect(logs[2].notes, equals('Day 1')); // Oldest
      });

      test('Entries can be filtered by symptom', () async {
        final now = DateTime.now();
        
        // Create entries with different symptoms
        final fatigueLog = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: now,
          notes: 'Fatigue entry',
          triggers: [],
          createdAt: now,
          updatedAt: now,
        );

        final headacheLog = HealthLogModel(
          id: '',
          symptom: 'Headache',
          severity: 'Moderate',
          loggedAt: now.add(const Duration(hours: 1)),
          notes: 'Headache entry',
          triggers: [],
          createdAt: now.add(const Duration(hours: 1)),
          updatedAt: now.add(const Duration(hours: 1)),
        );

        await healthLogService.saveHealthLog(uid: testUserId, healthLog: fatigueLog);
        await healthLogService.saveHealthLog(uid: testUserId, healthLog: headacheLog);

        // Get symptom history
        final headacheLogs = await healthLogService.watchSymptomHistory(
          uid: testUserId,
          symptom: 'Headache',
        ).first;

        expect(headacheLogs.length, equals(1));
        expect(headacheLogs[0].symptom, equals('Headache'));
        expect(headacheLogs[0].notes, equals('Headache entry'));
      });
    });

    // ==================== ERROR HANDLING TESTS ====================
    group('Error Handling', () {
      test('Service throws error when no user is authenticated', () async {
        // Create a mock auth service that returns null for currentUser
        final noAuthService = _MockAuthService('');
        AuthService.instance = noAuthService;
        
        // Create a test service with the no-auth service
        final noAuthTestService = _TestHealthLogService(noAuthService, firestoreService);

        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: DateTime.now(),
          notes: 'Test',
          triggers: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(
          () async => await noAuthTestService.saveHealthLog(healthLog: logEntry),
          throwsA(isA<StateError>()),
        );
      });

      test('Service can delete health log entries', () async {
        final now = DateTime.now();
        final logEntry = HealthLogModel(
          id: '',
          symptom: 'Fatigue',
          severity: 'Mild',
          loggedAt: now,
          notes: 'To be deleted',
          triggers: [],
          createdAt: now,
          updatedAt: now,
        );

        final savedLog = await healthLogService.saveHealthLog(
          uid: testUserId,
          healthLog: logEntry,
        );

        // Delete the entry
        await healthLogService.deleteHealthLog(
          uid: testUserId,
          healthLogId: savedLog.id,
        );

        // Verify entry is deleted
        final docRef = fakeFirestore
            .collection('users')
            .doc(testUserId)
            .collection('health_logs')
            .doc(savedLog.id);
        
        final doc = await docRef.get();
        expect(doc.exists, false);
      });
    });
  });
}

// ==================== HELPER FUNCTIONS ====================

class _TestHealthLogService {
  _TestHealthLogService(this._authService, this._firestoreService);

  final _MockAuthService _authService;
  final _TestFirestoreService _firestoreService;

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

class _TestFirestoreService extends FirestoreService {
  _TestFirestoreService(this.fakeFirestore) : super.forTesting();

  final FakeFirebaseFirestore fakeFirestore;

  @override
  CollectionReference<Map<String, dynamic>> healthLogsForUser(String uid) {
    return fakeFirestore
        .collection('users')
        .doc(uid)
        .collection('health_logs')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data() ?? {},
          toFirestore: (data, _) => data,
        );
  }
}

class _MockAuthService extends AuthService {
  _MockAuthService(this.mockUid);

  final String mockUid;

  @override
  firebase_auth.User? get currentUser {
    if (mockUid.isEmpty) return null;

    return _MockFirebaseUser(mockUid);
  }
}

class _MockFirebaseUser extends Fake implements firebase_auth.User {
  _MockFirebaseUser(this.uid);

  @override
  final String uid;

  @override
  String? get email => 'test@example.com';

  @override
  String? get displayName => 'Test User';
}
