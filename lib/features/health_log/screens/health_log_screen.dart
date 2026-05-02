import 'package:flutter/material.dart' hide Icons;

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/auth_service.dart';
import '../../../services/health_log_service.dart';
import '../models/health_log_model.dart';

class HealthLogScreen extends StatefulWidget {
  const HealthLogScreen({super.key});

  @override
  State<HealthLogScreen> createState() => _HealthLogScreenState();
}

class _HealthLogScreenState extends State<HealthLogScreen> {
  static const _symptoms = ['Fatigue', 'Headache', 'Nausea', 'Dizziness'];

  String _selectedSymptom = 'Fatigue';

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: Text('Sign in to view health logs.')),
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
                child: StreamBuilder<List<HealthLogModel>>(
                  stream: HealthLogService.instance.watchHealthLogs(),
                  builder: (context, snapshot) {
                    final logs = snapshot.data ?? const <HealthLogModel>[];

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Health Log',
                                  style: TextStyle(
                                    fontSize: 27,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => Navigator.of(context).pushNamed(
                                  AppRouter.addHealthLogRoute,
                                ),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: const Icon(
                                    AppIcons.add,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: const [
                              Expanded(
                                child: _FeatureTile(
                                  icon: AppIcons.monitor_heart_outlined,
                                  label: 'Symptom',
                                  tint: Color(0xFFFB7185),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _FeatureTile(
                                  icon: AppIcons.favorite_border_rounded,
                                  label: 'Vitals',
                                  tint: Color(0xFF34D399),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: _FeatureTile(
                                  icon: AppIcons.menu_book_outlined,
                                  label: 'Journal',
                                  tint: Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Entries',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showSymptomPicker,
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: AppColors.primary,
                                  padding: EdgeInsets.zero,
                                ),
                                icon: const Icon(AppIcons.tune_rounded, size: 15),
                                label: const Text(
                                  'Filter',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _SymptomSelector(
                            value: _selectedSymptom,
                            symptoms: _symptoms,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedSymptom = value);
                            },
                          ),
                          const SizedBox(height: 14),
                          _RecentEntriesSection(logs: logs),
                          const SizedBox(height: 18),
                          Text(
                            'Symptom History',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          StreamBuilder<List<HealthLogModel>>(
                            stream: HealthLogService.instance.watchSymptomHistory(
                              symptom: _selectedSymptom,
                            ),
                            builder: (context, historySnapshot) {
                              final history = historySnapshot.data ??
                                  const <HealthLogModel>[];

                              if (history.isEmpty) {
                                return _EmptyState(
                                  title: 'No $_selectedSymptom history yet',
                                  message:
                                      'Log this symptom a few times and it will appear here automatically.',
                                );
                              }

                              return Column(
                                children: history
                                    .map(
                                      (log) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: _EntryCard(
                                          icon: AppIcons.monitor_heart_outlined,
                                          iconColor: _severityColor(log.severity),
                                          title: log.symptom,
                                          subtitle: log.severity,
                                          subtitleColor:
                                              _severityColor(log.severity),
                                          time: _formatTimestamp(log.loggedAt),
                                          body: log.notes,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
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

  void _showSymptomPicker() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Choose symptom history',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                for (final symptom in _symptoms)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(symptom),
                    trailing: symptom == _selectedSymptom
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _selectedSymptom = symptom);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${MaterialLocalizations.of(context).formatShortDate(local)} • ${TimeOfDay.fromDateTime(local).format(context)}';
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return const Color(0xFF10B981);
      case 'moderate':
        return const Color(0xFFF59E0B);
      case 'severe':
        return const Color(0xFFF97316);
      case 'extreme':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }
}

class _SymptomSelector extends StatelessWidget {
  const _SymptomSelector({
    required this.value,
    required this.symptoms,
    required this.onChanged,
  });

  final String value;
  final List<String> symptoms;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(AppIcons.keyboard_arrow_down_rounded),
          items: symptoms
              .map(
                (symptom) => DropdownMenuItem<String>(
                  value: symptom,
                  child: Text(symptom),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _RecentEntriesSection extends StatelessWidget {
  const _RecentEntriesSection({required this.logs});

  final List<HealthLogModel> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const _EmptyState(
        title: 'No logs yet',
        message: 'Save your first symptom log to start building your history.',
      );
    }

    return Column(
      children: logs
          .take(4)
          .map(
            (log) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _EntryCard(
                icon: AppIcons.monitor_heart_outlined,
                iconColor: _severityColor(log.severity),
                title: log.symptom,
                subtitle: log.severity,
                subtitleColor: _severityColor(log.severity),
                time: _formatTimestamp(context, log.loggedAt),
                body: log.notes,
              ),
            ),
          )
          .toList(),
    );
  }

  static Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'mild':
        return const Color(0xFF10B981);
      case 'moderate':
        return const Color(0xFFF59E0B);
      case 'severe':
        return const Color(0xFFF97316);
      case 'extreme':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  static String _formatTimestamp(BuildContext context, DateTime dateTime) {
    final local = dateTime.toLocal();
    return '${MaterialLocalizations.of(context).formatShortDate(local)} • ${TimeOfDay.fromDateTime(local).format(context)}';
  }
}

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tint.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: tint),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
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

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.time,
    this.subtitleColor,
    this.body,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color? subtitleColor;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(28),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: subtitleColor ?? AppColors.textPrimary,
                  ),
                ),
                if (body != null && body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    body!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.35,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
