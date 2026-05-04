import 'package:flutter/material.dart' hide Icons;

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/appointment_service.dart';
import '../models/appointment_model.dart';

class AppointmentDetailScreen extends StatefulWidget {
  const AppointmentDetailScreen({super.key, this.appointment});

  final AppointmentModel? appointment;

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late final TextEditingController _completionNotesController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _completionNotesController = TextEditingController(
      text: widget.appointment?.completionNotes ?? '',
    );
  }

  @override
  void dispose() {
    _completionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final isCompleted = appointment?.isCompleted ?? false;

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
                        onPressed: appointment == null
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  AppRouter.addAppointmentRoute,
                                  arguments: appointment,
                                ),
                        icon: const Icon(Icons.edit_outlined),
                        splashRadius: 20,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFFE2E8F0),
                      child: Text(
                        appointment?.avatarLabel ?? 'AP',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      appointment?.doctorName ?? 'Appointment Details',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Center(
                    child: Text(
                      appointment?.specialty ?? 'Tap edit to add details',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (appointment != null)
                    Center(
                      child: _StatusPill(
                        label: isCompleted ? 'Completed' : 'Upcoming',
                        filled: isCompleted,
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
                  _DetailCard(
                    child: Column(
                      children: [
                        _TitleMetaRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: AppColors.primary,
                          title: appointment == null
                              ? 'No appointment loaded'
                              : _formatDateTime(appointment.appointmentDateTime),
                          subtitle: appointment == null
                              ? 'Open this screen from an appointment'
                              : '${appointment.durationMinutes} min',
                        ),
                        const SizedBox(height: 14),
                        _PrimarySoftAction(
                          label: appointment?.visitType ?? 'Visit type',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TitleMetaRow(
                          icon: appointment?.visitType.toLowerCase().contains('tele') == true
                              ? Icons.videocam_outlined
                              : Icons.location_on_outlined,
                          iconColor: AppColors.textSecondary,
                          title: appointment?.visitType ?? 'Visit Type',
                          subtitle: appointment?.visitType.toLowerCase().contains('tele') == true
                              ? (appointment?.meetingLink ?? 'No meeting link saved')
                              : (appointment?.location ?? 'No location saved'),
                          titleWeight: FontWeight.w700,
                        ),
                        const SizedBox(height: 14),
                        _SecondaryAction(
                          label: appointment?.visitType.toLowerCase().contains('tele') == true
                              ? 'Open Meeting Link'
                              : 'Get Directions',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REASON FOR VISIT',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          appointment?.reason ?? 'No reason provided yet.',
                          style: const TextStyle(
                            fontSize: 13.5,
                            height: 1.38,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailCard(
                    borderColor: const Color(0xFFD5DFF4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BadgeIcon(icon: Icons.auto_awesome),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment?.isAiSummaryEnabled == false
                                    ? 'AI Summary Disabled'
                                    : 'AI Summary Pending',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appointment?.isAiSummaryEnabled == false
                                    ? 'This appointment will not generate a pre-visit summary.'
                                    : 'Your personalized pre-visit summary and recommended questions will be generated 24 hours before your appointment.',
                                style: const TextStyle(
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
                  if (appointment != null && !isCompleted) ...[
                    const Text(
                      'Completion Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _TextAreaCard(controller: _completionNotesController),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _completeAppointment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Mark Completed'),
                      ),
                    ),
                  ] else if (appointment != null && isCompleted) ...[
                    const Text(
                      'Completion Notes',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _DetailCard(
                      child: Text(
                        appointment.completionNotes?.isNotEmpty == true
                            ? appointment.completionNotes!
                            : 'No completion notes saved.',
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _completeAppointment() async {
    final appointment = widget.appointment;
    if (appointment == null || _completionNotesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add completion notes before marking complete.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await AppointmentService.instance.completeAppointment(
        appointmentId: appointment.id,
        completionNotes: _completionNotesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment marked complete.')),
      );

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete appointment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final localDate = dateTime.toLocal();
    return '${MaterialLocalizations.of(context).formatMediumDate(localDate)} • ${TimeOfDay.fromDateTime(localDate).format(context)}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.filled});

  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? const Color(0xFFE7F7F1) : const Color(0xFFFDF4E5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: filled ? const Color(0xFF0B8F6C) : const Color(0xFFD97706),
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

class _TextAreaCard extends StatelessWidget {
  const _TextAreaCard({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        maxLines: 4,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
          hintText: 'What happened after the visit?',
        ),
      ),
    );
  }
}
