import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../models/user_model.dart';

final authControllerProvider = Provider<AuthControllerBase>((ref) {
  return AuthController();
});

abstract class AuthControllerBase {
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required int age,
    String? gender,
  });

  Future<void> loginUser({
    required String email,
    required String password,
  });

  Future<void> logoutUser();
}

class AuthController implements AuthControllerBase {
  final AuthService _authService = AuthService.instance;
  final FirestoreService _firestoreService = FirestoreService.instance;

  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required int age,
    String? gender,
  }) async {
    final credential = await _authService.signUp(
      email: email,
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      age: age,
      gender: gender,
    );

    await _firestoreService.saveUserProfile(user);
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    await _authService.login(
      email: email,
      password: password,
    );
  }

  Future<void> logoutUser() async {
    await _authService.logout();
  }
}