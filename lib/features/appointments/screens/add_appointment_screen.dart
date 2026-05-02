import 'package:flutter/material.dart' hide Icons;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/appointment_service.dart';
import '../models/appointment_model.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key, this.appointment});

  final AppointmentModel? appointment;

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _doctorNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _locationController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime _selectedDateTime = DateTime.now().add(const Duration(days: 1));
  bool _isTelehealth = true;
  bool _aiSummaryEnabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final appointment = widget.appointment;
    if (appointment != null) {
      _doctorNameController.text = appointment.doctorName;
      _specialtyController.text = appointment.specialty;
      _locationController.text = appointment.location ?? '';
      _meetingLinkController.text = appointment.meetingLink ?? '';
      _reasonController.text = appointment.reason;
      _selectedDateTime = appointment.appointmentDateTime;
      _isTelehealth = appointment.visitType.toLowerCase().contains('tele');
      _aiSummaryEnabled = appointment.isAiSummaryEnabled;
    } else {
      _doctorNameController.text = 'Dr. Robert Smith';
      _specialtyController.text = 'Primary Care';
      _meetingLinkController.text = 'zoom.us/j/123456789';
      _reasonController.text = 'Routine check-up for thyroid levels.';
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _specialtyController.dispose();
    _locationController.dispose();
    _meetingLinkController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Appointment' : 'New Appointment',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _FieldLabel('Doctor or Provider'),
                      const SizedBox(height: 8),
                      _TextFieldCard(
                        controller: _doctorNameController,
                        leadingIcon: Icons.person_outline_rounded,
                        hintText: 'Dr. Robert Smith',
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Specialty'),
                      const SizedBox(height: 8),
                      _TextFieldCard(
                        controller: _specialtyController,
                        leadingIcon: AppIcons.auto_awesome,
                        hintText: 'Primary Care',
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Visit Type'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _VisitTypeChip(
                              icon: Icons.videocam_outlined,
                              label: 'Telehealth',
                              selected: _isTelehealth,
                              onTap: () => setState(() => _isTelehealth = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _VisitTypeChip(
                              icon: Icons.location_on_outlined,
                              label: 'In-Person',
                              selected: !_isTelehealth,
                              onTap: () => setState(() => _isTelehealth = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: const [
                          Expanded(child: _FieldLabel('Date')),
                          SizedBox(width: 10),
                          Expanded(child: _FieldLabel('Time')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _PickField(
                              text: _formatDate(context, _selectedDateTime),
                              trailingIcon: Icons.calendar_today_outlined,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _PickField(
                              text: _formatTime(context, _selectedDateTime),
                              trailingIcon: AppIcons.access_time_rounded,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isTelehealth) ...[
                        const _FieldLabel('Meeting Link'),
                        const SizedBox(height: 8),
                        _TextFieldCard(
                          controller: _meetingLinkController,
                          leadingIcon: Icons.link_rounded,
                          hintText: 'zoom.us/j/123456789',
                        ),
                      ] else ...[
                        const _FieldLabel('Location'),
                        const SizedBox(height: 8),
                        _TextFieldCard(
                          controller: _locationController,
                          leadingIcon: Icons.location_on_outlined,
                          hintText: '123 Medical Center Blvd, Suite 400',
                        ),
                      ],
                      const SizedBox(height: 16),
                      const _FieldLabel('Reason for Visit'),
                      const SizedBox(height: 8),
                      _TextFieldCard(
                        controller: _reasonController,
                        hintText: 'Describe the reason for the visit',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDDE7FF)),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'AI Pre-Visit Summary',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Automatically prepare questions and health trends 24 hours before your visit.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      height: 1.35,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _aiSummaryEnabled,
                              thumbColor: const WidgetStatePropertyAll(
                                AppColors.white,
                              ),
                              trackColor: WidgetStateProperty.resolveWith(
                                (states) => states.contains(WidgetState.selected)
                                    ? AppColors.primary
                                    : const Color(0xFFDDE7FF),
                              ),
                              onChanged: (value) {
                                setState(() => _aiSummaryEnabled = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveAppointment,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isEditing ? 'Update Appointment' : 'Save Appointment',
                        ),
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

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (selectedTime == null) {
      return;
    }

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _saveAppointment() async {
    if (_doctorNameController.text.trim().isEmpty ||
        _specialtyController.text.trim().isEmpty ||
        _reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a provider, specialty, and reason.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final saved = await AppointmentService.instance.saveAppointment(
        appointment: AppointmentModel(
          id: widget.appointment?.id ?? '',
          doctorName: _doctorNameController.text.trim(),
          specialty: _specialtyController.text.trim(),
          appointmentDateTime: _selectedDateTime,
          durationMinutes: widget.appointment?.durationMinutes ?? 30,
          visitType: _isTelehealth ? 'Telehealth Visit' : 'In-Person Visit',
          reason: _reasonController.text.trim(),
          status: widget.appointment?.status ?? 'upcoming',
          location: _isTelehealth ? null : _locationController.text.trim(),
          meetingLink: _isTelehealth ? _meetingLinkController.text.trim() : null,
          avatarLabel: _initials(_doctorNameController.text.trim()),
          isAiSummaryEnabled: _aiSummaryEnabled,
          completionNotes: widget.appointment?.completionNotes,
          completedAt: widget.appointment?.completedAt,
          createdAt: widget.appointment?.createdAt ?? DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appointment == null
                ? 'Appointment saved.'
                : 'Appointment updated.',
          ),
        ),
      );
      Navigator.pop(context, saved);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save appointment: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((part) => part.isEmpty ? '' : part[0]).join();
    return initials.isEmpty ? 'AP' : initials.toUpperCase();
  }

  static String _formatDate(BuildContext context, DateTime dateTime) {
    return MaterialLocalizations.of(context).formatMediumDate(dateTime);
  }

  static String _formatTime(BuildContext context, DateTime dateTime) {
    return TimeOfDay.fromDateTime(dateTime).format(context);
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _TextFieldCard extends StatelessWidget {
  const _TextFieldCard({
    required this.controller,
    required this.hintText,
    this.leadingIcon,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? leadingIcon;
  final int maxLines;

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
        maxLines: maxLines,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          prefixIcon: leadingIcon == null
              ? null
              : Icon(leadingIcon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _VisitTypeChip extends StatelessWidget {
  const _VisitTypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickField extends StatelessWidget {
  const _PickField({
    required this.text,
    required this.trailingIcon,
    required this.onTap,
  });

  final String text;
  final IconData trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(trailingIcon, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
