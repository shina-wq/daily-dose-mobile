import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () async {
      if (!mounted) {
        return;
      }

      final currentUser = ref.read(authStateProvider).asData?.value;

      Navigator.of(context).pushNamedAndRemoveUntil(
        currentUser == null ? AppRouter.landingRoute : AppRouter.homeRoute,
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(
              size: 92,
              iconSize: 40,
              backgroundColor: AppColors.primary,
              iconColor: AppColors.white,
              borderRadius: 24,
              showShadow: false,
            ),
            const SizedBox(height: 20),
            Text(
              'DailyDose',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your AI Health Companion',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}