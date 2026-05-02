import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';
import '../features/onboarding/models/onboarding_model.dart';
import '../features/profile/models/profile_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get users => _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> appointmentsForUser(String uid) {
    return users.doc(uid).collection('appointments');
  }

  CollectionReference<Map<String, dynamic>> healthLogsForUser(String uid) {
    return users.doc(uid).collection('health_logs');
  }

  Future<void> saveUserProfile(UserModel user) async {
    await users.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<void> saveOnboardingData({
    required String uid,
    required OnboardingModel onboarding,
  }) async {
    await users.doc(uid).set(
      {
        'onboarding': onboarding.toMap(),
      },
      SetOptions(merge: true),
    );
  }

  Stream<ProfileModel?> watchProfile(String uid) {
    return users.doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data == null) {
        return null;
      }

      return ProfileModel.fromMap(data);
    });
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await users.doc(profile.uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }
}