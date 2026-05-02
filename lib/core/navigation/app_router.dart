import 'package:flutter/material.dart';
import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/appointments/screens/add_appointment_screen.dart';
import '../../features/appointments/screens/appointment_detail_screen.dart';
import '../../features/appointments/models/appointment_model.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/landing_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/health_log/screens/health_log_screen.dart';
import '../../features/health_log/screens/add_log_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/medications/screens/add_medication_screen.dart';
import '../../features/onboarding/screens/onboarding_flow_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import 'bottom_nav.dart';

class AppRouter {
  AppRouter._();

  static const String homeRoute = '/';
  static const String splashRoute = '/splash';
  static const String landingRoute = '/landing';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String onboardingRoute = '/onboarding';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String medicationsRoute = '/medications';
  static const String addMedicationRoute = '/medications/add';
  static const String appointmentsRoute = '/appointments';
  static const String addAppointmentRoute = '/appointments/add';
  static const String appointmentDetailRoute = '/appointments/detail';
  static const String healthLogRoute = '/health-log';
  static const String addHealthLogRoute = '/health-log/add';
  static const String aiChatRoute = '/ai-chat';
  static const String profileRoute = '/profile';
  static const String notificationsRoute = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case landingRoute:
        return MaterialPageRoute(builder: (_) => const LandingScreen());

      case homeRoute:
        return MaterialPageRoute(builder: (_) => const AppNavigationShell());

      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case registerRoute:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingFlowScreen());

      case forgotPasswordRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case medicationsRoute:
        return MaterialPageRoute(builder: (_) => const MedicationsScreen());

      case addMedicationRoute:
        return MaterialPageRoute(builder: (_) => const AddMedicationScreen());

      case appointmentsRoute:
        return MaterialPageRoute(
          builder: (_) => const AppNavigationShell(initialIndex: 2),
        );

      case addAppointmentRoute:
        return MaterialPageRoute(
          builder: (_) => AddAppointmentScreen(
            appointment: settings.arguments is AppointmentModel
                ? settings.arguments as AppointmentModel
                : null,
          ),
        );

      case appointmentDetailRoute:
        return MaterialPageRoute(
          builder: (_) => AppointmentDetailScreen(
            appointment: settings.arguments is AppointmentModel
                ? settings.arguments as AppointmentModel
                : null,
          ),
        );

      case healthLogRoute:
        return MaterialPageRoute(builder: (_) => const HealthLogScreen());

      case addHealthLogRoute:
        return MaterialPageRoute(builder: (_) => const AddLogScreen());

      case aiChatRoute:
        return MaterialPageRoute(builder: (_) => const AiChatScreen());

      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

      case notificationsRoute:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      default:
        return MaterialPageRoute(builder: (_) => const AppNavigationShell());
    }
  }
}
