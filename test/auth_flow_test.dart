import 'dart:async';

import 'package:daily_dose_mobile/core/navigation/app_router.dart';
import 'package:daily_dose_mobile/core/providers/auth_provider.dart';
import 'package:daily_dose_mobile/core/providers/storage_provider.dart';
import 'package:daily_dose_mobile/features/auth/providers/auth_controller.dart';
import 'package:daily_dose_mobile/features/auth/screens/login_screen.dart';
import 'package:daily_dose_mobile/features/auth/screens/register_screen.dart';
import 'package:daily_dose_mobile/features/dashboard/models/home_dashboard_model.dart';
import 'package:daily_dose_mobile/features/dashboard/providers/home_provider.dart';
import 'package:daily_dose_mobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:daily_dose_mobile/features/splash/screens/splash_screen.dart';
import 'package:daily_dose_mobile/services/api_service.dart';
import 'package:daily_dose_mobile/core/utils/token_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/src/framework.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthController implements AuthControllerBase {
  FakeAuthController({this.loginError, this.registerError});

  final Object? loginError;
  final Object? registerError;

  int registerCallCount = 0;
  int loginCallCount = 0;
  int logoutCallCount = 0;

  String? lastRegisteredName;
  String? lastRegisteredEmail;
  String? lastRegisteredPassword;
  int? lastRegisteredAge;

  String? lastLoggedInEmail;
  String? lastLoggedInPassword;

  @override
  Future<void> registerUser({
    required String name,
    required String email,
    required String password,
    required int age,
    String? gender,
  }) async {
    registerCallCount += 1;
    lastRegisteredName = name;
    lastRegisteredEmail = email;
    lastRegisteredPassword = password;
    lastRegisteredAge = age;

    if (registerError != null) {
      throw registerError!;
    }
  }

  @override
  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    loginCallCount += 1;
    lastLoggedInEmail = email;
    lastLoggedInPassword = password;

    if (loginError != null) {
      throw loginError!;
    }
  }

  @override
  Future<void> logoutUser() async {
    logoutCallCount += 1;
  }
}

class FakeUserStorage extends UserStorage {
  int saveBasicCallCount = 0;
  int clearCallCount = 0;

  @override
  Future<void> saveBasic({String? uid, required String email, String? name}) async {
    saveBasicCallCount += 1;
  }

  @override
  Future<Map<String, String?>> readBasic() async {
    return const {'uid': null, 'email': null, 'name': null, 'onboarded': null};
  }

  @override
  Future<void> setOnboarded(bool value) async {}

  @override
  Future<bool> isOnboarded() async => false;

  @override
  Future<void> clear() async {
    clearCallCount += 1;
  }
}

class FakeApiService extends ApiService {
  FakeApiService(this.payload);

  final Map<String, dynamic> payload;

  @override
  Future<Map<String, dynamic>> fetchHomeDashboard(String uid) async {
    return payload;
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<String> pushedRouteNames = [];
  final List<String> replacedRouteNames = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRouteNames.add(route.settings.name ?? '<unnamed>');
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    replacedRouteNames.add(newRoute?.settings.name ?? '<unnamed>');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class _AuthStateLabel extends ConsumerWidget {
  const _AuthStateLabel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) => Text(user == null ? 'Signed out' : 'Signed in'),
      loading: () => const Text('Loading'),
      error: (error, stackTrace) => Text('Error: $error'),
    );
  }
}

Widget _buildTestApp({
  required Widget home,
  String initialRoute = '/test-start',
  List<Override> overrides = const [],
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      navigatorObservers: navigatorObservers,
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/test-start':
          case AppRouter.loginRoute:
          case AppRouter.registerRoute:
          case AppRouter.splashRoute:
            page = home;
            break;
          case AppRouter.homeRoute:
            page = const _RouteShell(title: 'Home Screen');
            break;
          case AppRouter.onboardingRoute:
            page = const _RouteShell(title: 'Onboarding Screen');
            break;
          case AppRouter.landingRoute:
            page = const _RouteShell(title: 'Landing Screen');
            break;
          case AppRouter.loginRoute:
            page = const _RouteShell(title: 'Login Route');
            break;
          case AppRouter.registerRoute:
            page = const _RouteShell(title: 'Register Route');
            break;
          default:
            page = const _RouteShell(title: 'Unknown Route');
        }

        return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
      },
    ),
  );
}

class _RouteShell extends StatelessWidget {
  const _RouteShell({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(title)),
    );
  }
}

Future<void> _enterLoginForm(WidgetTester tester, {required String email, required String password}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), password);
}

Future<void> _enterRegisterForm(
  WidgetTester tester, {
  required String name,
  required String email,
  required String age,
  required String password,
  required String confirmPassword,
}) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), name);
  await tester.enterText(fields.at(1), email);
  await tester.enterText(fields.at(2), age);
  await tester.enterText(fields.at(3), password);
  await tester.enterText(fields.at(4), confirmPassword);
}

Future<void> _setLargeTestSurface(WidgetTester tester) async {
  tester.binding.window.physicalSizeTestValue = const Size(430, 1200);
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  addTearDown(() {
    tester.binding.window.clearPhysicalSizeTestValue();
    tester.binding.window.clearDevicePixelRatioTestValue();
  });
}

void main() {
  group('Register screen', () {
    testWidgets('user cannot sign up with invalid email', (tester) async {
      await _setLargeTestSurface(tester);
      final authController = FakeAuthController();
      final userStorage = FakeUserStorage();

      await tester.pumpWidget(
        _buildTestApp(
          home: const RegisterScreen(),
          initialRoute: AppRouter.registerRoute,
          overrides: [
            authControllerProvider.overrideWithValue(authController),
            userStorageProvider.overrideWithValue(userStorage),
          ],
        ),
      );

      await _enterRegisterForm(
        tester,
        name: 'Sarah Jenkins',
        email: 'invalid-email',
        age: '35',
        password: 'StrongPass123',
        confirmPassword: 'StrongPass123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(authController.registerCallCount, 0);
    });

    testWidgets('user cannot sign up with weak password', (tester) async {
      await _setLargeTestSurface(tester);
      final authController = FakeAuthController();
      final userStorage = FakeUserStorage();

      await tester.pumpWidget(
        _buildTestApp(
          home: const RegisterScreen(),
          initialRoute: AppRouter.registerRoute,
          overrides: [
            authControllerProvider.overrideWithValue(authController),
            userStorageProvider.overrideWithValue(userStorage),
          ],
        ),
      );

      await _enterRegisterForm(
        tester,
        name: 'Sarah Jenkins',
        email: 'sarah@example.com',
        age: '35',
        password: 'short',
        confirmPassword: 'short',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pump();

      expect(find.text('Password must be at least 8 characters'), findsOneWidget);
      expect(authController.registerCallCount, 0);
    });

    testWidgets('user can sign up and is routed to onboarding', (tester) async {
      await _setLargeTestSurface(tester);
      final authController = FakeAuthController();
      final userStorage = FakeUserStorage();

      await tester.pumpWidget(
        _buildTestApp(
          home: const RegisterScreen(),
          initialRoute: AppRouter.registerRoute,
          overrides: [
            authControllerProvider.overrideWithValue(authController),
            userStorageProvider.overrideWithValue(userStorage),
          ],
        ),
      );

      await _enterRegisterForm(
        tester,
        name: 'Sarah Jenkins',
        email: 'sarah@example.com',
        age: '35',
        password: 'StrongPass123',
        confirmPassword: 'StrongPass123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Create Account'));
      await tester.pumpAndSettle();

      expect(authController.registerCallCount, 1);
      expect(find.text('Onboarding Screen'), findsOneWidget);
    });
  });

  group('Login screen', () {
    testWidgets('user can log in and is routed to home', (tester) async {
      await _setLargeTestSurface(tester);
      final authController = FakeAuthController();
      final userStorage = FakeUserStorage();
      final navigatorObserver = _RecordingNavigatorObserver();

      await tester.pumpWidget(
        _buildTestApp(
          home: const LoginScreen(),
          initialRoute: AppRouter.loginRoute,
          overrides: [
            authControllerProvider.overrideWithValue(authController),
            userStorageProvider.overrideWithValue(userStorage),
          ],
          navigatorObservers: [navigatorObserver],
        ),
      );

      await _enterLoginForm(
        tester,
        email: 'sarah@example.com',
        password: 'StrongPass123',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(authController.loginCallCount, 1);
      expect(navigatorObserver.pushedRouteNames, contains(AppRouter.homeRoute));
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('wrong credentials show error', (tester) async {
      await _setLargeTestSurface(tester);
      final authController = FakeAuthController(loginError: Exception('Invalid credentials'));
      final userStorage = FakeUserStorage();

      await tester.pumpWidget(
        _buildTestApp(
          home: const LoginScreen(),
          initialRoute: AppRouter.loginRoute,
          overrides: [
            authControllerProvider.overrideWithValue(authController),
            userStorageProvider.overrideWithValue(userStorage),
          ],
        ),
      );

      await _enterLoginForm(
        tester,
        email: 'sarah@example.com',
        password: 'wrong-password',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Invalid credentials'), findsOneWidget);
      expect(find.text('Home Screen'), findsNothing);
    });
  });

  group('Startup and auth state', () {
    testWidgets('user stays logged in after app restart', (tester) async {
      await _setLargeTestSurface(tester);
      final mockUser = MockUser(uid: 'user-123', email: 'sarah@example.com');
      final navigatorObserver = _RecordingNavigatorObserver();
      final controller = StreamController<User?>();
      addTearDown(controller.close);

      await tester.pumpWidget(
        _buildTestApp(
          home: const SplashScreen(),
          initialRoute: AppRouter.splashRoute,
          overrides: [
            authStateProvider.overrideWith((ref) => controller.stream),
          ],
          navigatorObservers: [navigatorObserver],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      controller.add(mockUser);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(navigatorObserver.pushedRouteNames, contains(AppRouter.homeRoute));
    });

    testWidgets('auth state updates UI correctly', (tester) async {
      await _setLargeTestSurface(tester);
      final controller = StreamController<User?>();
      addTearDown(controller.close);
      final mockUser = MockUser(uid: 'user-123', email: 'sarah@example.com');

      await tester.pumpWidget(
        _buildTestApp(
          home: const _AuthStateLabel(),
          initialRoute: '/test-start',
          overrides: [
            authStateProvider.overrideWith((ref) => controller.stream),
          ],
        ),
      );

      controller.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Signed out'), findsOneWidget);

      controller.add(mockUser);
      await tester.pumpAndSettle();
      expect(find.text('Signed in'), findsOneWidget);
    });
  });

  group('Home data', () {
    testWidgets('displays the correct user data after login or sign up', (tester) async {
      await _setLargeTestSurface(tester);
      final mockUser = MockUser(uid: 'user-123', email: 'sarah@example.com');
      final apiService = FakeApiService({
        'user': {'name': 'Sarah Jenkins', 'initials': 'SJ'},
        'aiInsight': 'Your adherence looks strong this week.',
        'quickStats': {
          'healthScore': 92,
          'adherencePercent': 96,
          'adherenceSubtitle': 'Excellent streak',
          'nextAppointment': {
            'doctorName': 'Dr. Patel',
            'label': 'Next visit in 3 days',
          },
        },
        'notifications': {'hasUnread': true},
        'medications': [
          {
            'id': 'med-1',
            'medicationId': 'medication-1',
            'name': 'Metformin',
            'dosage': '500 mg',
            'details': 'Morning dose',
            'status': 'pending',
            'isTaken': false,
          },
        ],
      });

      await tester.pumpWidget(
        _buildTestApp(
          home: const DashboardScreen(),
          overrides: [
            authStateProvider.overrideWith((ref) => Stream<User?>.value(mockUser)),
            apiServiceProvider.overrideWithValue(apiService),
            backgroundTasksInitializerProvider.overrideWith((ref) async {}),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('Your adherence looks strong this week.'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);
      expect(find.text('Dr. Patel'), findsOneWidget);
    });
  });
}
