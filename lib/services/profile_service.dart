import '../features/profile/models/profile_model.dart';
import 'auth_service.dart';
import 'firestore_service.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();

  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  String _requireUid() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      throw StateError('No authenticated user found.');
    }

    return uid;
  }

  Stream<ProfileModel> watchCurrentUserProfile() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      throw StateError('No authenticated user found.');
    }

    return _firestoreService.watchProfile(currentUser.uid).map(
      (profile) =>
          profile ??
          ProfileModel.empty(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
          ),
    );
  }

  Future<void> updateCurrentUserProfile(ProfileModel profile) async {
    final uid = _requireUid();
    final currentUser = _authService.currentUser;
    final normalized = profile.copyWith(
      uid: uid,
      email: profile.email.isEmpty ? (currentUser?.email ?? '') : profile.email,
    );

    await _firestoreService.updateProfile(normalized);
  }
}