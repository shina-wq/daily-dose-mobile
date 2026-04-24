import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';

class HealthLogScreen extends StatelessWidget {
  const HealthLogScreen({super.key});

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
                                Icons.add,
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
                              icon: Icons.monitor_heart_outlined,
                              label: 'Symptom',
                              tint: Color(0xFFFB7185),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeatureTile(
                              icon: Icons.favorite_border_rounded,
                              label: 'Vitals',
                              tint: Color(0xFF34D399),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeatureTile(
                              icon: Icons.menu_book_outlined,
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
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                            icon: const Icon(Icons.tune_rounded, size: 15),
                            label: const Text(
                              'Filter',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const _SectionHeader('TODAY'),
                      const SizedBox(height: 8),
                      const _EntryCard(
                        icon: Icons.monitor_heart_outlined,
                        iconColor: Color(0xFFFB7185),
                        title: 'Fatigue',
                        subtitle: 'Moderate',
                        subtitleColor: Color(0xFFF59E0B),
                        time: '2:30 PM',
                        body: 'Felt unusually tired after lunch. Didn\'t sleep well last night.',
                      ),
                      const SizedBox(height: 8),
                      const _EntryCard(
                        icon: Icons.favorite_border_rounded,
                        iconColor: Color(0xFF34D399),
                        title: 'Blood Pressure',
                        subtitle: '120/80 mmHg',
                        time: '8:00 AM',
                        compact: true,
                      ),
                      const SizedBox(height: 12),
                      const _SectionHeader('YESTERDAY'),
                      const SizedBox(height: 8),
                      const _EntryCard(
                        icon: Icons.menu_book_outlined,
                        iconColor: Color(0xFFF59E0B),
                        title: 'Daily Notes',
                        subtitle: 'Completed 30 minutes of light walking. Felt good overall.',
                        time: '9:00 PM',
                        compact: true,
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.9,
        color: AppColors.textSecondary,
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
    this.compact = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String time;
  final Color? subtitleColor;
  final String? body;
  final bool compact;

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
                    fontSize: compact ? 13.5 : 12.5,
                    fontWeight: compact ? FontWeight.w600 : FontWeight.w700,
                    color: subtitleColor ?? AppColors.textPrimary,
                  ),
                ),
                if (body != null) ...[
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
