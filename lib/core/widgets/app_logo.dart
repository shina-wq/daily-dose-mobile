import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.iconSize = 42,
    this.backgroundColor = AppColors.surface,
    this.iconColor = AppColors.primary,
    this.borderRadius = 28,
    this.showShadow = true,
  });

  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.black.withAlpha(16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Center(
        child: Icon(
          AppIcons.heart_pulse,
          size: iconSize,
          color: iconColor,
          semanticLabel: 'DailyDose logo',
        ),
      ),
    );
  }
}