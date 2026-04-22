import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Sarah',
  );
  final TextEditingController _goalsController = TextEditingController();
  final TextEditingController _dobController = TextEditingController(
    text: 'Oct 12, 1985',
  );
  final TextEditingController _medicationSearchController =
      TextEditingController();
  final TextEditingController _conditionSearchController =
      TextEditingController();

  int _currentStep = 0;
  DateTime? _dateOfBirth = DateTime(1985, 10, 12);
  String _sexAtBirth = 'Female';
  String _checkInTime = '8:00 AM';
  int _communicationStyleIndex = 1;

  final List<_MedicationItem> _medications = [
    const _MedicationItem(name: 'Metformin', dose: '500mg', schedule: 'Twice daily'),
    const _MedicationItem(
      name: 'Levothyroxine',
      dose: '50mcg',
      schedule: 'Once daily (morning)',
    ),
  ];

  final List<_ConditionItem> _conditions = [
    _ConditionItem(name: 'Type 2 Diabetes', icon: Icons.monitor_heart_outlined, selected: true),
    _ConditionItem(name: 'Hypertension', icon: Icons.favorite_border_rounded),
    _ConditionItem(name: 'Hypothyroidism', icon: Icons.water_drop_outlined, selected: true),
    _ConditionItem(name: 'Asthma', icon: Icons.air_rounded),
    _ConditionItem(name: 'Rheumatoid Arthritis', icon: Icons.timeline_rounded),
  ];

  final List<_CommunicationStyleItem> _communicationStyles = const [
    _CommunicationStyleItem(
      title: 'Clinical & Direct',
      subtitle: 'Focuses on data, facts, and straightforward advice.',
      icon: Icons.assignment_outlined,
    ),
    _CommunicationStyleItem(
      title: 'Empathetic & Supportive',
      subtitle: 'Gentle encouragement and warm guidance.',
      icon: Icons.favorite_border_rounded,
    ),
    _CommunicationStyleItem(
      title: 'Coach & Motivator',
      subtitle: 'Proactive, goal-oriented, and structured.',
      icon: Icons.gps_fixed_rounded,
    ),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _goalsController.dispose();
    _dobController.dispose();
    _medicationSearchController.dispose();
    _conditionSearchController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 30, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
    );

    if (pickedDate != null) {
      setState(() {
        _dateOfBirth = pickedDate;
        _dobController.text = _formatDate(pickedDate);
      });
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      return;
    }

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRouter.landingRoute);
  }

  void _continue() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep += 1;
      });
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 18),
                          _OnboardingHeader(
                            currentStep: _currentStep,
                            totalSteps: 4,
                            onBack: _goBack,
                          ),
                          const SizedBox(height: 22),
                          _buildStepContent(),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: AppDimensions.buttonHeight,
                            child: FilledButton(
                              onPressed: _continue,
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(_currentStep == 3 ? 'Complete Setup' : 'Continue'),
                            ),
                          ),
                          if (_currentStep == 1) ...[
                            const SizedBox(height: 14),
                            TextButton(
                              onPressed: _continue,
                              child: const Text('Skip for now'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildMedicationsStep();
      case 2:
        return _buildConditionsStep();
      case 3:
        return _buildPersonalizationStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Tell us about yourself',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This baseline information helps DailyDose tailor your daily check-ins and insights.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        const _StepLabel('Preferred Name'),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: _inputDecoration(
            hintText: 'Your name',
            prefixIcon: Icons.person_outline_rounded,
          ),
        ),
        const SizedBox(height: 18),
        const _StepLabel('Date of Birth'),
        const SizedBox(height: 8),
        TextField(
          readOnly: true,
          onTap: _selectDateOfBirth,
          controller: _dobController,
          decoration: _inputDecoration(
            hintText: 'Select date',
            prefixIcon: Icons.calendar_today_outlined,
          ),
        ),
        const SizedBox(height: 18),
        const _StepLabel('Sex at Birth'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sexAtBirth,
          items: const [
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Intersex', child: Text('Intersex')),
            DropdownMenuItem(value: 'Prefer not to say', child: Text('Prefer not to say')),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _sexAtBirth = value;
            });
          },
          decoration: _inputDecoration(
            hintText: 'Select an option',
            prefixIcon: Icons.multiline_chart_rounded,
          ),
        ),
        const SizedBox(height: 18),
        const _StepLabel('Your goals (Optional)'),
        const SizedBox(height: 8),
        TextField(
          controller: _goalsController,
          maxLines: 3,
          decoration: _inputDecoration(
            hintText: 'E.g., I want to manage my fatigue and keep track of my medication schedule...',
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Add your medications',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'We\'ll help you track your doses and discover how they affect your daily symptoms.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _medicationSearchController,
          decoration: _inputDecoration(
            hintText: 'Search for a medication...',
            prefixIcon: Icons.search,
          ),
        ),
        const SizedBox(height: 16),
        ..._medications.map(_buildMedicationCard),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {
            setState(() {
              _medications.add(
                _MedicationItem(
                  name: 'New Medication',
                  dose: '10mg',
                  schedule: 'Once daily',
                ),
              );
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('Add another medication'),
        ),
      ],
    );
  }

  Widget _buildMedicationCard(_MedicationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F8F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: Color(0xFF12B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FA),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.dose,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.schedule,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What conditions are you managing?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'This helps DailyDose personalize your insights and prepare relevant questions for your doctors.',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _conditionSearchController,
          decoration: _inputDecoration(
            hintText: 'Search conditions...',
            prefixIcon: Icons.search,
          ),
        ),
        const SizedBox(height: 14),
        ..._conditions.map(_buildConditionTile),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Add unlisted condition'),
        ),
      ],
    );
  }

  Widget _buildConditionTile(_ConditionItem condition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            condition.selected = !condition.selected;
          });
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: condition.selected ? const Color(0xFFF0F5FF) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: condition.selected ? AppColors.primary : AppColors.border,
              width: condition.selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: condition.selected
                      ? AppColors.primary
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  condition.icon,
                  color: condition.selected
                      ? AppColors.white
                      : AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  condition.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: condition.selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(
                condition.selected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: condition.selected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalizationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Personalize your AI',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'How would you like your health assistant to communicate with you?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 24),
        const _StepLabel('COMMUNICATION STYLE'),
        const SizedBox(height: 10),
        ...List.generate(
          _communicationStyles.length,
          (index) => _buildCommunicationStyleTile(index, _communicationStyles[index]),
        ),
        const SizedBox(height: 18),
        const _StepLabel('DAILY CHECK-IN TIME'),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _checkInTime,
          decoration: _inputDecoration(
            hintText: 'Select time',
            prefixIcon: Icons.access_time_rounded,
          ),
          items: const [
            DropdownMenuItem(value: '7:00 AM', child: Text('7:00 AM')),
            DropdownMenuItem(value: '8:00 AM', child: Text('8:00 AM')),
            DropdownMenuItem(value: '9:00 AM', child: Text('9:00 AM')),
            DropdownMenuItem(value: '7:00 PM', child: Text('7:00 PM')),
          ],
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _checkInTime = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCommunicationStyleTile(int index, _CommunicationStyleItem style) {
    final isSelected = _communicationStyleIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            _communicationStyleIndex = index;
          });
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0F5FF) : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  style.icon,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      style.subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    const monthLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthLabels[date.month - 1];
    return '$month ${date.day}, ${date.year}';
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Row(
            children: List.generate(totalSteps, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : const Color(0xFFE7ECF5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _StepLabel extends StatelessWidget {
  const _StepLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MedicationItem {
  const _MedicationItem({
    required this.name,
    required this.dose,
    required this.schedule,
  });

  final String name;
  final String dose;
  final String schedule;
}

class _ConditionItem {
  _ConditionItem({
    required this.name,
    required this.icon,
    this.selected = false,
  });

  final String name;
  final IconData icon;
  bool selected;
}

class _CommunicationStyleItem {
  const _CommunicationStyleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}