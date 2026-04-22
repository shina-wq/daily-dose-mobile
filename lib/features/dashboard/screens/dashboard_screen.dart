import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
	const DashboardScreen({super.key});

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
									padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: const [
											_DashboardHeader(),
											SizedBox(height: 18),
											_AiInsightCard(),
											SizedBox(height: 14),
											_QuickStatsRow(),
											SizedBox(height: 20),
											_MedicationsSection(),
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

class _DashboardHeader extends StatelessWidget {
	const _DashboardHeader();

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
					child: const Text(
						'SJ',
						style: TextStyle(
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
						children: const [
							Text(
								'Good morning,',
								style: TextStyle(
									fontSize: 13,
									fontWeight: FontWeight.w500,
									color: AppColors.textSecondary,
								),
							),
							SizedBox(height: 2),
							Text(
								'Sarah Jenkins',
								style: TextStyle(
									fontSize: 26,
									fontWeight: FontWeight.w700,
									letterSpacing: -0.3,
									color: AppColors.textPrimary,
								),
							),
						],
					),
				),
				Container(
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
									Icons.notifications_none_rounded,
									size: 20,
									color: AppColors.textPrimary,
								),
							),
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
			],
		);
	}
}

class _AiInsightCard extends StatelessWidget {
	const _AiInsightCard();

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
									Icons.auto_awesome,
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
					const Text(
						'You\'ve taken 100% of your medication this week. '
						'Based on your recent logs, morning fatigue is decreasing. '
						'Dr. Smith is scheduled for tomorrow-let\'s prepare.',
						style: TextStyle(
							fontSize: 14.5,
							height: 1.45,
							color: Color(0xFF374151),
						),
					),
					const SizedBox(height: 12),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
						decoration: BoxDecoration(
							color: AppColors.white,
							borderRadius: BorderRadius.circular(999),
							border: Border.all(color: const Color(0xFFE1EAFD)),
						),
						child: const Row(
							children: [
								Icon(
									Icons.description_outlined,
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
									Icons.arrow_forward,
									size: 18,
									color: AppColors.primary,
								),
							],
						),
					),
				],
			),
		);
	}
}

class _QuickStatsRow extends StatelessWidget {
	const _QuickStatsRow();

	@override
	Widget build(BuildContext context) {
		return const Row(
			children: [
				Expanded(
					child: _QuickStatCard(
						icon: Icons.monitor_heart_outlined,
						iconTint: Color(0xFF10B981),
						badge: '92%',
						badgeColor: Color(0xFFD1FAE5),
						title: 'Health Score',
						subtitle: 'Excellent adherence',
					),
				),
				SizedBox(width: 10),
				Expanded(
					child: _QuickStatCard(
						icon: Icons.calendar_month_outlined,
						iconTint: Color(0xFFF59E0B),
						title: 'Dr. Smith',
						subtitle: 'Tomorrow, 10:00 AM',
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
	const _MedicationsSection();

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: const [
				Row(
					children: [
						Expanded(
							child: Text(
								"Today's Medications",
								style: TextStyle(
									fontSize: 21,
									fontWeight: FontWeight.w700,
									letterSpacing: -0.2,
								),
							),
						),
						Text(
							'See all',
							style: TextStyle(
								fontSize: 13,
								fontWeight: FontWeight.w600,
								color: AppColors.primary,
							),
						),
					],
				),
				SizedBox(height: 10),
				_MedicationTile(
					name: 'Levothyroxine',
					details: '50mcg • Taken at 8:05 AM',
					icon: Icons.check,
					iconColor: Color(0xFF86D8C6),
					surfaceColor: AppColors.white,
					borderColor: AppColors.border,
					isDone: true,
				),
				SizedBox(height: 10),
				_MedicationTile(
					name: 'Metformin',
					details: '500mg • 8:00 PM',
					icon: Icons.link_rounded,
					iconColor: AppColors.primary,
					surfaceColor: AppColors.white,
					borderColor: AppColors.primary,
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
										color: isDone
												? AppColors.textSecondary
												: AppColors.textPrimary,
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
						child: isDone
								? const Icon(Icons.check, size: 14, color: AppColors.white)
								: null,
					),
				],
			),
		);
	}
}
