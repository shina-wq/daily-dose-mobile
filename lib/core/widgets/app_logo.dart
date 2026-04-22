import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    final logoIconData = FaIconData(
      IconData(
        FontAwesomeIcons.heartPulse.codePoint,
        fontFamily: FontAwesomeIcons.heartPulse.fontFamily,
        fontPackage: FontAwesomeIcons.heartPulse.fontPackage,
        matchTextDirection: false,
      ),
    );

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
        child: FaIcon(
          logoIconData,
          size: iconSize,
          color: iconColor,
          semanticLabel: 'DailyDose logo',
        ),
      ),
    );
  }
}