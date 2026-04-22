import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/widgets/app_logo.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 700;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _LandingHero(isCompact: isCompact),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.lg,
                            AppDimensions.xl,
                            AppDimensions.lg,
                            AppDimensions.lg,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Manage your health\nwith confidence.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontSize: isCompact ? 30 : 34,
                                  height: isCompact ? 1.04 : 1.1,
                                  letterSpacing: -0.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.md),
                              Text(
                                'DailyDose uses intelligent insights to\nhelp you track symptoms, manage\nmedications, and prepare for doctor\nvisits.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.45,
                                  fontSize: isCompact ? 16 : 17,
                                ),
                              ),
                              SizedBox(height: isCompact ? 26 : 34),
                              SizedBox(
                                height: AppDimensions.buttonHeight,
                                child: FilledButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRouter.registerRoute);
                                  },
                                  style: FilledButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text('Get Started'),
                                ),
                              ),
                              const SizedBox(height: AppDimensions.md),
                              SizedBox(
                                height: AppDimensions.buttonHeight,
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRouter.loginRoute);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(color: AppColors.border),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: const Text('Log In'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero({required this.isCompact});

  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(36),
      ),
      child: Container(
        height: isCompact ? 290 : 340,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors : [
              Color(0xFFF7F9FF),
              Color(0xFFEFF3FD),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -38,
              right: -24,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(22),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -56,
              left: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: const AppLogo(),
            ),
          ],
        ),
      ),
    );
  }
}