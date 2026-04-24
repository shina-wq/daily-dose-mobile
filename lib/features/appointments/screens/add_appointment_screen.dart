import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  bool _isTelehealth = true;
  bool _aiSummaryEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'New Appointment',
          style: TextStyle(fontWeight: FontWeight.w700),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: _fieldDecoration(),
                        child: const Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: Color(0xFFE8F0FF),
                              child: Icon(
                                Icons.person_outline_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Dr. Robert Smith',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
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
                              onTap: () =>
                                  setState(() => _isTelehealth = false),
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
                          const Expanded(
                            child: _InlineField(
                              text: 'Oct 24, 2023',
                              trailingIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: _InlineField(
                              text: '10:00 AM',
                              trailingIcon: Icons.access_time_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Meeting Link'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: _fieldDecoration(),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.link_rounded,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'zoom.us/j/123456789',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _FieldLabel('Reason for Visit'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: _fieldDecoration(),
                        child: const Text(
                          'Routine check-up for thyroid levels.\n'
                          'Experiencing slightly more fatigue\n'
                          'than usual in the afternoons.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
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
                                    'Automatically prepare questions and health trends '
                                    '24 hours before your visit.',
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
                              activeColor: AppColors.white,
                              activeTrackColor: AppColors.primary,
                              onChanged: (value) {
                                setState(() => _aiSummaryEnabled = value);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Appointment saved.')),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save Appointment'),
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

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border),
    );
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

class _InlineField extends StatelessWidget {
  const _InlineField({required this.text, required this.trailingIcon});

  final String text;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
