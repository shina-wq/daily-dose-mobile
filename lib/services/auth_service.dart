// for signUp, login, logout, currentUser
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService();

  AuthService._([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  // Made non-final so tests can inject a mock instance.
  static AuthService instance = AuthService._();

  late final FirebaseAuth _auth;

  /// Replace the active singleton with a test instance backed by [auth].
  ///
  /// Tests should call `AuthService.setInstanceForTesting(mockAuth)` before
  /// pumping widgets that read `AuthService.instance`.
  static void setInstanceForTesting([FirebaseAuth? auth]) {
    instance = AuthService._(auth);
  }

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}