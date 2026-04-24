import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        splashRadius: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 2),
                      const Expanded(
                        child: Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert_rounded),
                        splashRadius: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFE2E8F0),
                      child: Text(
                        'AP',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Dr. Anita Patel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Center(
                    child: Text(
                      'Primary Care',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuickActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _QuickActionButton(
                        icon: Icons.call_outlined,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _DetailCard(
                    child: Column(
                      children: [
                        _TitleMetaRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.primary,
                          title: 'Tuesday, Nov 12, 2023',
                          subtitle: '2:30 PM - 3:00 PM (30 min)',
                        ),
                        SizedBox(height: 14),
                        _PrimarySoftAction(label: 'Add to Calendar'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleMetaRow(
                          icon: Icons.location_on_outlined,
                          iconColor: AppColors.textSecondary,
                          title: 'In-Person Visit',
                          subtitle: '123 Medical Center Blvd\nSuite 400\nNew York, NY 10001',
                          titleWeight: FontWeight.w700,
                        ),
                        SizedBox(height: 14),
                        _SecondaryAction(label: 'Get Directions'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'REASON FOR VISIT',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Annual physical examination and routine bloodwork check.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.38,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const _DetailCard(
                    borderColor: Color(0xFFD5DFF4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _BadgeIcon(icon: Icons.auto_awesome),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Summary Pending',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Your personalized pre-visit summary and recommended questions will be generated 24 hours before your appointment.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: const BorderSide(color: AppColors.border),
                        foregroundColor: AppColors.textPrimary,
                        backgroundColor: AppColors.white,
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Cancel Appointment',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFFEAF0FF),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 17, color: AppColors.primary),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child, this.borderColor = AppColors.border});

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

class _TitleMetaRow extends StatelessWidget {
  const _TitleMetaRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleWeight = FontWeight.w600,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final FontWeight titleWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BadgeIcon(icon: icon, iconColor: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: titleWeight,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  const _BadgeIcon({
    required this.icon,
    this.iconColor = AppColors.primary,
  });

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Icon(icon, size: 15, color: iconColor),
    );
  }
}

class _PrimarySoftAction extends StatelessWidget {
  const _PrimarySoftAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 37,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F7F1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFC2EADB)),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0B8F6C),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 37,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
