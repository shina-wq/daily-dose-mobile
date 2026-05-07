import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'services/notification_service.dart';

class DailyDoseApp extends StatefulWidget {
  const DailyDoseApp({super.key});

  @override
  State<DailyDoseApp> createState() => _DailyDoseAppState();
}

class _DailyDoseAppState extends State<DailyDoseApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPendingNotificationRoute();
    });
  }

  void _openPendingNotificationRoute() {
    final route = NotificationService.instance.consumePendingNotificationRoute();
    if (route == null) {
      return;
    }

    AppRouter.navigatorKey.currentState?.pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: AppRouter.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'DailyDose',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}