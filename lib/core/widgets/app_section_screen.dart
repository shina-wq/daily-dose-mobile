import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppSectionScreen extends StatelessWidget {
  const AppSectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.xl),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.md),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (child != null) ...[
                    const SizedBox(height: AppDimensions.xl),
                    child!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}