import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = type == ButtonType.primary;

    return SizedBox(
      height: AppDimensions.buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getForegroundColor(),
          side: type == ButtonType.outline
              ? const BorderSide(color: AppColors.border)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                text,
                style: isPrimary
                    ? AppTextStyles.buttonText
                    : AppTextStyles.labelMedium,
              ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppColors.primary;
      case ButtonType.secondary:
        return AppColors.secondary;
      case ButtonType.outline:
        return Colors.white;
    }
  }

  Color _getForegroundColor() {
    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
        return Colors.white;
      case ButtonType.outline:
        return AppColors.textPrimary;
    }
  }
}