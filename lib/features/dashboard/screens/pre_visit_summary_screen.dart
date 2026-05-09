import 'package:flutter/material.dart' hide Icons;

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../models/home_dashboard_model.dart';

class PreVisitSummaryScreen extends StatelessWidget {
  const PreVisitSummaryScreen({super.key, this.summary});

  final PreVisitSummaryModel? summary;

  @override
  Widget build(BuildContext context) {
    final resolvedSummary = summary ??
        PreVisitSummaryModel.fromJson(const {
          'title': 'Pre-Visit Summary',
          'overview': 'Your pre-visit summary is ready to review.',
          'medications': ['No active medications found'],
          'symptoms': ['No symptom data available'],
          'missedDoses': 0,
          'insights': ['Not enough data yet to build insights.'],
          'trends': ['Not enough data yet to identify trends.'],
          'suggestedQuestions': ['What should I ask during this visit?'],
        });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(AppIcons.arrow_back_rounded),
                          splashRadius: 20,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 4),
                        const Expanded(
                          child: Text(
                            'Pre-Visit Summary',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SummaryHeroCard(summary: resolvedSummary),
                      const SizedBox(height: 12),
                      _SummaryListCard(
                        title: 'Medications',
                        icon: AppIcons.medication_outlined,
                        items: resolvedSummary.medications,
                      ),
                      const SizedBox(height: 10),
                      _SummaryListCard(
                        title: 'Symptoms',
                        icon: AppIcons.favorite_outline_rounded,
                        items: resolvedSummary.symptoms,
                      ),
                      const SizedBox(height: 10),
                      _SummaryListCard(
                        title: 'Insights',
                        icon: AppIcons.lightbulb_outline_rounded,
                        items: resolvedSummary.insights,
                      ),
                      const SizedBox(height: 10),
                      _SummaryListCard(
                        title: 'Trends',
                        icon: AppIcons.multiline_chart_rounded,
                        items: resolvedSummary.trends,
                      ),
                      const SizedBox(height: 10),
                      _SummaryListCard(
                        title: 'Suggested Doctor Questions',
                        icon: AppIcons.help_circle,
                        items: resolvedSummary.suggestedQuestions,
                        numberItems: true,
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({required this.summary});

  final PreVisitSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    final hasMissedDoses = summary.missedDoses > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEAF2FF),
                ),
                child: const Icon(
                  AppIcons.description_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  summary.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            summary.overview,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: hasMissedDoses ? const Color(0xFFFFF7ED) : const Color(0xFFE8F8F1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: hasMissedDoses ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
              ),
            ),
            child: Text(
              hasMissedDoses
                  ? '${summary.missedDoses} missed dose${summary.missedDoses == 1 ? '' : 's'} detected'
                  : 'No missed doses detected',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasMissedDoses ? const Color(0xFFB45309) : const Color(0xFF047857),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryListCard extends StatelessWidget {
  const _SummaryListCard({
    required this.title,
    required this.icon,
    required this.items,
    this.numberItems = false,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final bool numberItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final prefix = numberItems ? '${index + 1}. ' : '• ';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '$prefix$item',
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
