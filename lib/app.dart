import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';

class DailyDoseApp extends StatelessWidget {
  const DailyDoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DailyDose',
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}