import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    super.key,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.visitType,
    required this.avatarLabel,
    this.badgeText,
    this.location,
    this.isHighlighted = false,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.primaryActionColor,
    this.primaryActionTextColor,
    this.secondaryActionColor,
    this.secondaryActionTextColor,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.footerHint,
  });

  final String doctorName;
  final String specialty;
  final String dateTime;
  final String visitType;
  final String avatarLabel;
  final String? badgeText;
  final String? location;
  final bool isHighlighted;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final Color? primaryActionColor;
  final Color? primaryActionTextColor;
  final Color? secondaryActionColor;
  final Color? secondaryActionTextColor;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;
  final String? footerHint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : AppColors.border,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFE6ECF7),
                child: Text(
                  avatarLabel,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDF4E5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _MetaRow(icon: Icons.event_note_rounded, text: dateTime),
          const SizedBox(height: 8),
          _MetaRow(
            icon: visitType.toLowerCase().contains('tele')
                ? Icons.videocam_outlined
                : Icons.location_on_outlined,
            text: visitType,
          ),
          if (location != null) ...[
            const SizedBox(height: 8),
            _MetaRow(icon: Icons.place_outlined, text: location!),
          ],
          if (primaryActionLabel != null || secondaryActionLabel != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (secondaryActionLabel != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondaryAction ?? () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                            secondaryActionTextColor ?? AppColors.textPrimary,
                        side: BorderSide(
                          color: (secondaryActionColor ?? AppColors.border)
                              .withAlpha(140),
                        ),
                        backgroundColor: AppColors.surface,
                        minimumSize: const Size.fromHeight(42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        secondaryActionLabel!,
                        style: TextStyle(
                          color:
                              secondaryActionTextColor ?? AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (secondaryActionLabel != null && primaryActionLabel != null)
                  const SizedBox(width: 10),
                if (primaryActionLabel != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryAction ?? () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryActionColor ?? AppColors.primary,
                        foregroundColor:
                            primaryActionTextColor ?? AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        minimumSize: const Size.fromHeight(42),
                      ),
                      child: Text(
                        primaryActionLabel!,
                        style: TextStyle(
                          color: primaryActionTextColor ?? AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (footerHint != null) ...[
            const SizedBox(height: 10),
            Text(
              footerHint!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
