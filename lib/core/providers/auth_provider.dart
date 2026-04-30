import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/medication_background_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Initialize background tasks when user is authenticated
final backgroundTasksInitializerProvider = FutureProvider<void>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  return authState.when(
    data: (user) async {
      if (user != null) {
        // Initialize daily medication tasks for the authenticated user
        await MedicationBackgroundService.instance.initializeDailyTasks(user.uid);
      }
    },
    loading: () async {},
    error: (error, stackTrace) async {
      // Handle error silently, log if needed
      print('Error initializing background tasks: $error');
    },
  );
});
