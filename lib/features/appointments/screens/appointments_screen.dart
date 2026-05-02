import 'package:flutter/material.dart' hide Icons;

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/appointment_service.dart';
import '../../../services/auth_service.dart';
import '../models/appointment_model.dart';
import '../widgets/appointment_card.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Sign in to view appointments.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: StreamBuilder<List<AppointmentModel>>(
                  stream: AppointmentService.instance.watchAppointments(),
                  builder: (context, snapshot) {
                    final allAppointments = snapshot.data ?? const <AppointmentModel>[];
                    final appointments = _filterAppointments(allAppointments);

                    return SingleChildScrollView(
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
                                    AppIcons.add,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _AppointmentsSegmentedControl(
                            selectedIndex: _selectedTab,
                            onChanged: (index) => setState(() => _selectedTab = index),
                          ),
                          const SizedBox(height: 16),
                          if (appointments.isEmpty)
                            const _EmptyState(
                              title: 'No appointments yet',
                              message:
                                  'Create an appointment to start tracking visits, completion notes, and follow-up actions.',
                            )
                          else
                            Column(
                              children: appointments
                                  .map(
                                    (appointment) => Padding(
                                      padding: const EdgeInsets.only(bottom: 12),
                                      child: AppointmentCard(
                                        doctorName: appointment.doctorName,
                                        specialty: appointment.specialty,
                                        dateTime: _formatDateTime(context, appointment.appointmentDateTime),
                                        visitType: appointment.visitType,
                                        avatarLabel: appointment.avatarLabel ?? _initials(appointment.doctorName),
                                        badgeText: _badgeText(appointment),
                                        location: appointment.location,
                                        isHighlighted: _isHighlighted(appointment),
                                        primaryActionLabel: appointment.isCompleted ? 'View Notes' : 'Details',
                                        secondaryActionLabel: 'Edit',
                                        primaryActionColor: appointment.isCompleted
                                            ? const Color(0xFFD7F2EA)
                                            : null,
                                        primaryActionTextColor: appointment.isCompleted
                                            ? const Color(0xFF0B8F6C)
                                            : null,
                                        onPrimaryAction: () => Navigator.pushNamed(
                                          context,
                                          AppRouter.appointmentDetailRoute,
                                          arguments: appointment,
                                        ),
                                        onSecondaryAction: () => Navigator.pushNamed(
                                          context,
                                          AppRouter.addAppointmentRoute,
                                          arguments: appointment,
                                        ),
                                        footerHint: appointment.isCompleted
                                            ? 'Completion notes saved on ${_formatShortDate(context, appointment.completedAt ?? appointment.updatedAt)}.'
                                            : 'Tap edit to update the schedule or visit details.',
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<AppointmentModel> _filterAppointments(List<AppointmentModel> appointments) {
    final now = DateTime.now();
    final filtered = appointments.where((appointment) {
      final isPast = appointment.isCompleted || appointment.appointmentDateTime.isBefore(now);
      return _selectedTab == 0 ? !isPast : isPast;
    }).toList();

    filtered.sort((left, right) {
      return _selectedTab == 0
          ? left.appointmentDateTime.compareTo(right.appointmentDateTime)
          : right.appointmentDateTime.compareTo(left.appointmentDateTime);
    });

    return filtered;
  }

  String? _badgeText(AppointmentModel appointment) {
    if (appointment.isCompleted) {
      return 'Completed';
    }

    final difference = appointment.appointmentDateTime.difference(DateTime.now()).inDays;
    if (difference == 0) {
      return 'Today';
    }
    if (difference == 1) {
      return 'Tomorrow';
    }
    if (difference > 1 && difference <= 7) {
      return 'This week';
    }

    return null;
  }

  bool _isHighlighted(AppointmentModel appointment) {
    return !appointment.isCompleted && appointment.appointmentDateTime.difference(DateTime.now()).inDays <= 1;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((part) => part.isEmpty ? '' : part[0]).join();
    return initials.isEmpty ? 'AP' : initials.toUpperCase();
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${MaterialLocalizations.of(context).formatMediumDate(local)} - ${TimeOfDay.fromDateTime(local).format(context)}';
  }

  String _formatShortDate(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(context).formatMediumDate(dateTime.toLocal());
  }
}

class _AppointmentsSegmentedControl extends StatelessWidget {
  const _AppointmentsSegmentedControl({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentPill(
              label: 'Upcoming',
              selected: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SegmentPill(
              label: 'Past',
              selected: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPill extends StatelessWidget {
  const _SegmentPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
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
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
