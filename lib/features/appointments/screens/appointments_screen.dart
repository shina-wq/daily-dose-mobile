import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Appointments',
                              style: TextStyle(
                                fontSize: 33,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRouter.addAppointmentRoute,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            child: Ink(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8F0FF),
                                border: Border.all(
                                  color: const Color(0xFFD6E4FF),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _AppointmentsSegmentedControl(),
                      const SizedBox(height: 16),
                      AppointmentCard(
                        doctorName: 'Dr. Robert Smith',
                        specialty: 'Endocrinologist',
                        dateTime: 'Oct 24, 2023 - 10:00 AM',
                        visitType: 'Telehealth Visit',
                        avatarLabel: 'RS',
                        badgeText: 'Tomorrow',
                        isHighlighted: true,
                        primaryActionLabel: 'View Pre-Visit Summary',
                        footerHint:
                            'AI has prepared 3 questions for your visit.',
                        onPrimaryAction: () {},
                      ),
                      const SizedBox(height: 12),
                      AppointmentCard(
                        doctorName: 'Dr. Anita Patel',
                        specialty: 'Primary Care',
                        dateTime: 'Nov 12, 2023 - 2:30 PM',
                        visitType: 'In-Person',
                        location: '123 Medical Center Blvd, Suite 400',
                        avatarLabel: 'AP',
                        secondaryActionLabel: 'Reschedule',
                        primaryActionLabel: 'Details',
                        primaryActionColor: Color(0xFFD7F2EA),
                        secondaryActionColor: Color(0xFF9CA3AF),
                        primaryActionTextColor: Color(0xFF0B8F6C),
                        onPrimaryAction: () => Navigator.pushNamed(
                          context,
                          AppRouter.appointmentDetailRoute,
                        ),
                        onSecondaryAction: () {},
                      ),
                    ],
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

class _AppointmentsSegmentedControl extends StatelessWidget {
  const _AppointmentsSegmentedControl();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Expanded(child: _SegmentPill(label: 'Upcoming', selected: true)),
          SizedBox(width: 6),
          Expanded(child: _SegmentPill(label: 'Past', selected: false)),
        ],
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: selected ? AppColors.white : AppColors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: selected ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
