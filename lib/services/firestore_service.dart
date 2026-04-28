import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/auth/models/user_model.dart';
import '../features/onboarding/models/onboarding_model.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get users => _firestore.collection('users');

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
}