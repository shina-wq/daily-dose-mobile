import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddLogScreen extends StatefulWidget {
  const AddLogScreen({super.key});

  @override
  State<AddLogScreen> createState() => _AddLogScreenState();
}

class _AddLogScreenState extends State<AddLogScreen> {
  String _selectedSymptom = 'Fatigue';
  String _selectedSeverity = 'Moderate';
  final Set<String> _triggers = <String>{'Poor Sleep', 'Physical Activity'};

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
                            icon: const Icon(Icons.arrow_back_rounded),
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
                        items: const ['Fatigue', 'Headache', 'Nausea', 'Dizziness'],
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
                        children: const [
                          Expanded(
                            child: _InlinePickField(
                              text: 'Today',
                              trailingIcon: Icons.calendar_today_outlined,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _InlinePickField(
                              text: '2:30 PM',
                              trailingIcon: Icons.access_time_rounded,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('Severity'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _SeverityChip(
                              label: 'Mild',
                              selected: _selectedSeverity == 'Mild',
                              onTap: () => setState(() => _selectedSeverity = 'Mild'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SeverityChip(
                              label: 'Moderate',
                              selected: _selectedSeverity == 'Moderate',
                              accent: true,
                              onTap: () => setState(() => _selectedSeverity = 'Moderate'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SeverityChip(
                              label: 'Severe',
                              selected: _selectedSeverity == 'Severe',
                              onTap: () => setState(() => _selectedSeverity = 'Severe'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _SeverityChip(
                              label: 'Extreme',
                              selected: _selectedSeverity == 'Extreme',
                              onTap: () => setState(() => _selectedSeverity = 'Extreme'),
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
                          _TriggerChip(
                            label: 'Poor Sleep',
                            selected: _triggers.contains('Poor Sleep'),
                            onTap: () => setState(() {
                              _toggleTrigger('Poor Sleep');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Stress',
                            selected: _triggers.contains('Stress'),
                            onTap: () => setState(() {
                              _toggleTrigger('Stress');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Missed Meal',
                            selected: _triggers.contains('Missed Meal'),
                            onTap: () => setState(() {
                              _toggleTrigger('Missed Meal');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Dehydration',
                            selected: _triggers.contains('Dehydration'),
                            onTap: () => setState(() {
                              _toggleTrigger('Dehydration');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Weather',
                            selected: _triggers.contains('Weather'),
                            onTap: () => setState(() {
                              _toggleTrigger('Weather');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Physical Activity',
                            selected: _triggers.contains('Physical Activity'),
                            onTap: () => setState(() {
                              _toggleTrigger('Physical Activity');
                            }),
                          ),
                          _TriggerChip(
                            label: 'Add Custom',
                            selected: false,
                            outlined: true,
                            onTap: null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const _FieldLabel('Notes'),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: _fieldDecoration(),
                        child: const Text(
                          'Felt unusually tired after lunch. Didn\'t sleep well last night after the late workout session.',
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Health log saved.')),
                          );
                          Navigator.of(context).pop();
                        },
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
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
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
  const _InlinePickField({required this.text, required this.trailingIcon});

  final String text;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    this.outlined = false,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = outlined
        ? AppColors.surface
        : selected
            ? AppColors.primary
            : AppColors.surface;
    final Color textColor = outlined
        ? AppColors.textSecondary
        : selected
            ? AppColors.white
            : AppColors.textSecondary;
    final Color borderColor = outlined
        ? AppColors.border
        : selected
            ? AppColors.primary
            : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: borderColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.3,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
