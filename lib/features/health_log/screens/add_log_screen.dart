import 'package:flutter/material.dart' hide Icons;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/health_log_service.dart';
import '../models/health_log_model.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  static const _symptoms = ['Fatigue', 'Headache', 'Nausea', 'Dizziness'];
  static const _severityLevels = ['Mild', 'Moderate', 'Severe', 'Extreme'];
  static const _triggerOptions = [
    'Poor Sleep',
    'Stress',
    'Missed Meal',
    'Dehydration',
    'Weather',
    'Physical Activity',
  ];

  String _selectedSymptom = 'Fatigue';
  String _selectedSeverity = 'Moderate';
  final Set<String> _triggers = <String>{'Poor Sleep', 'Physical Activity'};
  final _notesController = TextEditingController(
    text: 'Felt unusually tired after lunch. Didn\'t sleep well last night after the late workout session.',
  );
  DateTime _selectedDateTime = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(AppIcons.arrow_back_rounded),
                            splashRadius: 20,
                            visualDensity: VisualDensity.compact,
                          ),
                          const Expanded(
                            child: Text(
                              'Log Symptom',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const _FieldLabel('What are you experiencing?'),
                      const SizedBox(height: 8),
                      _DropdownField(
                        value: _selectedSymptom,
                        items: _symptoms,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedSymptom = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: const [
                          Expanded(child: _FieldLabel('Date')),
                          SizedBox(width: 12),
                          Expanded(child: _FieldLabel('Time')),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _InlinePickField(
                              text: MaterialLocalizations.of(context).formatMediumDate(_selectedDateTime),
                              trailingIcon: AppIcons.calendar_today_outlined,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InlinePickField(
                              text: TimeOfDay.fromDateTime(_selectedDateTime).format(context),
                              trailingIcon: AppIcons.access_time_rounded,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('Severity'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          for (final level in _severityLevels)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _SeverityChip(
                                  label: level,
                                  selected: _selectedSeverity == level,
                                  accent: level == 'Moderate',
                                  onTap: () => setState(() => _selectedSeverity = level),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('Possible Triggers (Optional)'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final trigger in _triggerOptions)
                            _TriggerChip(
                              label: trigger,
                              selected: _triggers.contains(trigger),
                              onTap: () => setState(() => _toggleTrigger(trigger)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('Notes'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: _fieldDecoration(),
                        child: TextField(
                          controller: _notesController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                            hintText: 'Add more details about what you felt.',
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isSaving ? null : _saveLog,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Save Entry'),
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

    if (selectedDate == null) return;

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

    if (selectedTime == null) return;

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

  Future<void> _saveLog() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add notes before saving the log.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await HealthLogService.instance.saveHealthLog(
        healthLog: HealthLogModel(
          id: '',
          symptom: _selectedSymptom,
          severity: _selectedSeverity,
          loggedAt: _selectedDateTime,
          notes: _notesController.text.trim(),
          triggers: _triggers.toList()..sort(),
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health log saved.')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save health log: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _toggleTrigger(String trigger) {
    if (_triggers.contains(trigger)) {
      _triggers.remove(trigger);
    } else {
      _triggers.add(trigger);
    }
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
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(AppIcons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(14),
          items: items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _InlinePickField extends StatelessWidget {
  const _InlinePickField({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
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

class _SeverityChip extends StatelessWidget {
  const _SeverityChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? (accent ? const Color(0xFFF59E0B) : AppColors.primary)
        : AppColors.border;
    final Color backgroundColor = selected
        ? (accent ? const Color(0xFFFFF7ED) : const Color(0xFFEFF4FF))
        : AppColors.surface;
    final Color textColor = selected
        ? (accent ? const Color(0xFFF59E0B) : AppColors.primary)
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _TriggerChip extends StatelessWidget {
  const _TriggerChip({
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
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.3,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
