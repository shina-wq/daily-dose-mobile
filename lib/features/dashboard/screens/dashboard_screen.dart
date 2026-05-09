import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../models/home_dashboard_model.dart';
import '../providers/home_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(backgroundTasksInitializerProvider);
    final homeAsync = ref.watch(homeDashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeAsync.when(
        data: (home) => _DashboardBody(home: home),
        loading: () => const _DashboardLoadingState(),
        error: (error, stackTrace) => _DashboardErrorState(
          errorMessage: '$error',
          onRetry: () => ref.invalidate(homeDashboardProvider),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.home});

  final HomeDashboardModel home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(homeDashboardProvider);
          await ref.read(homeDashboardProvider.future);
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  children: [
                    _DashboardHeader(
                      name: home.userName,
                      initials: home.userInitials,
                      hasUnreadNotifications: home.hasUnreadNotifications,
                    ),
                    const SizedBox(height: 18),
                    _AiInsightCard(
                      insight: home.aiInsight,
                      summary: home.preVisitSummary,
                    ),
                    const SizedBox(height: 14),
                    _PreVisitSummaryCard(summary: home.preVisitSummary),
                    const SizedBox(height: 14),
                    _QuickStatsRow(home: home),
                    const SizedBox(height: 20),
                    _MedicationsSection(medications: home.medications),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardLoadingState extends StatelessWidget {
  const _DashboardLoadingState();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      bottom: false,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _DashboardErrorState extends StatelessWidget {
  const _DashboardErrorState({
    required this.errorMessage,
    required this.onRetry,
  });

  final String errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Could not load home data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.name,
    required this.initials,
    required this.hasUnreadNotifications,
  });

  final String name;
  final String initials;
  final bool hasUnreadNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFD9BD), Color(0xFFDFA47A)],
            ),
            border: Border.all(color: AppColors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning,',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).pushNamed(AppRouter.notificationsRoute),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              color: AppColors.white,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    AppIcons.notifications_none_rounded,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (hasUnreadNotifications)
                  Positioned(
                    top: 8,
                    right: 9,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  const _AiInsightCard({
    required this.insight,
    required this.summary,
  });

  final String insight;
  final PreVisitSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFDDE6FC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primary,
                child: Icon(
                  AppIcons.auto_awesome,
                  size: 15,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 10),
              Text(
                'AI Daily Insight',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            insight,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.45,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.preVisitSummaryRoute,
              arguments: summary,
            ),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFE1EAFD)),
              ),
              child: const Row(
                children: [
                  Icon(
                    AppIcons.description_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View Pre-Visit Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    AppIcons.arrow_forward,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreVisitSummaryCard extends StatelessWidget {
  const _PreVisitSummaryCard({required this.summary});

  final PreVisitSummaryModel summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
          _SummarySection(title: 'Medications', items: summary.medications),
          const SizedBox(height: 10),
          _SummarySection(title: 'Symptoms', items: summary.symptoms),
          const SizedBox(height: 10),
          _SummarySection(title: 'Insights', items: summary.insights),
          const SizedBox(height: 10),
          _SummarySection(title: 'Trends', items: summary.trends),
          const SizedBox(height: 10),
          _SummarySection(
            title: 'Suggested Questions',
            items: summary.suggestedQuestions,
          ),
          const SizedBox(height: 10),
          _MissedDosePill(missedDoses: summary.missedDoses),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: _SummaryDot(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryDot extends StatelessWidget {
  const _SummaryDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

class _MissedDosePill extends StatelessWidget {
  const _MissedDosePill({required this.missedDoses});

  final int missedDoses;

  @override
  Widget build(BuildContext context) {
    final text = missedDoses > 0
        ? '$missedDoses missed dose${missedDoses == 1 ? '' : 's'}'
        : 'No missed doses detected';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: missedDoses > 0 ? const Color(0xFFFFF7ED) : const Color(0xFFE8F8F1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: missedDoses > 0 ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: missedDoses > 0 ? const Color(0xFFB45309) : const Color(0xFF047857),
        ),
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.home});

  final HomeDashboardModel home;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: AppIcons.monitor_heart_outlined,
            iconTint: const Color(0xFF10B981),
            badge: '${home.healthScore}%',
            badgeColor: const Color(0xFFD1FAE5),
            title: 'Health Score',
            subtitle: home.adherenceSubtitle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickStatCard(
            icon: AppIcons.calendar_month_outlined,
            iconTint: const Color(0xFFF59E0B),
            title: home.nextAppointmentDoctor,
            subtitle: home.nextAppointmentLabel,
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  const _QuickStatCard({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeColor,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final String? badge;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconTint.withAlpha(28),
                ),
                child: Icon(icon, size: 16, color: iconTint),
              ),
              if (badge != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationsSection extends StatelessWidget {
  const _MedicationsSection({required this.medications});

  final List<HomeMedicationItem> medications;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                "Today's Medications",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(AppRouter.medicationsRoute),
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (medications.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No medications for today yet.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          )
        else
          ...medications.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MedicationTile(
                name: item.name,
                details: item.details,
                icon: item.isTaken ? AppIcons.check : AppIcons.link_rounded,
                iconColor: item.isTaken ? const Color(0xFF86D8C6) : AppColors.primary,
                surfaceColor: AppColors.white,
                borderColor: item.isTaken ? AppColors.border : AppColors.primary,
                isDone: item.isTaken,
              ),
            ),
          ),
      ],
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.name,
    required this.details,
    required this.icon,
    required this.iconColor,
    required this.surfaceColor,
    required this.borderColor,
    this.isDone = false,
  });

  final String name;
  final String details;
  final IconData icon;
  final Color iconColor;
  final Color surfaceColor;
  final Color borderColor;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withAlpha(28),
            ),
            child: Icon(icon, size: 19, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDone ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone ? AppColors.transparent : AppColors.primary,
                width: 2,
              ),
              color: isDone ? iconColor : AppColors.transparent,
            ),
            child: isDone ? const Icon(AppIcons.check, size: 14, color: AppColors.white) : null,
          ),
        ],
      ),
    );
  }
}
