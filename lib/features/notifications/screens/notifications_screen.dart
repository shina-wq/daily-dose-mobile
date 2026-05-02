import 'package:flutter/material.dart' hide Icons;

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
	const NotificationsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				bottom: false,
				child: Center(
					child: ConstrainedBox(
						constraints: const BoxConstraints(maxWidth: 430),
						child: ListView(
							padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
							children: [
								_RowHeader(
									onBack: () => Navigator.of(context).maybePop(),
									onMarkAll: () {},
								),
								const SizedBox(height: 12),
								const _SectionHeader(title: 'NEW', countLabel: '2 unread'),
								const SizedBox(height: 8),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Pre-Visit Summary Ready',
										message:
											'Your AI-generated summary for Dr. Patel is ready to review before tomorrow\'s appointment.',
										timeLabel: '10m ago',
										icon: AppIcons.auto_awesome_rounded,
										iconBackground: Color(0xFFEAF2FF),
										iconColor: Color(0xFF4F8DF7),
										showUnreadDot: true,
									),
								),
								const SizedBox(height: 10),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Time for your Medication',
										message: 'It\'s time to take your afternoon dose of Metformin (500mg).',
										timeLabel: '11m ago',
										icon: AppIcons.medication_outlined,
										iconBackground: Color(0xFFFFF1E2),
										iconColor: Color(0xFFF59E0B),
										showUnreadDot: true,
									),
								),
								const SizedBox(height: 18),
								const _SectionHeader(title: 'YESTERDAY'),
								const SizedBox(height: 8),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Symptom Check-in',
										message:
											'We noticed you logged moderate fatigue yesterday. How are you feeling today?',
										timeLabel: 'Yesterday, 9:00 AM',
										icon: AppIcons.favorite_outline_rounded,
										iconBackground: Color(0xFFFFEBEE),
										iconColor: Color(0xFFEF4444),
									),
								),
								const SizedBox(height: 10),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Appointment Confirmed',
										message: 'Your telehealth visit with Dr. Smith is confirmed for Nov 12 at 2:30 PM.',
										timeLabel: 'Yesterday, 2:25 PM',
										icon: AppIcons.event_available_rounded,
										iconBackground: Color(0xFFE8F8F1),
										iconColor: Color(0xFF10B981),
									),
								),
								const SizedBox(height: 18),
								const _SectionHeader(title: 'EARLIER'),
								const SizedBox(height: 8),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Weekly Adherence Report',
										message: 'Great job! You achieved 95% medication adherence last week. Keep up the good work.',
										timeLabel: 'Oct 15, 8:00 AM',
										icon: AppIcons.bar_chart_rounded,
										iconBackground: Color(0xFFEAF8EE),
										iconColor: Color(0xFF22C55E),
										muted: true,
									),
								),
								const SizedBox(height: 10),
								const _NotificationCard(
									data: _NotificationCardData(
										title: 'Daily Health Tip',
										message: 'Staying hydrated can help manage your blood pressure. Try to drink at least 8 glasses of water today.',
										timeLabel: 'Oct 14, 9:00 AM',
										icon: AppIcons.lightbulb_outline_rounded,
										iconBackground: Color(0xFFF1F5F9),
										iconColor: Color(0xFF94A3B8),
										muted: true,
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

class _RowHeader extends StatelessWidget {
	const _RowHeader({required this.onBack, required this.onMarkAll});

	final VoidCallback onBack;
	final VoidCallback onMarkAll;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				SizedBox(
					width: 40,
					height: 40,
					child: IconButton(
						padding: EdgeInsets.zero,
						icon: const Icon(AppIcons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
						onPressed: onBack,
					),
				),
				const Expanded(
					child: Center(
						child: Text(
							'Notifications',
							style: TextStyle(
								fontSize: 16,
								fontWeight: FontWeight.w700,
								letterSpacing: -0.2,
								color: AppColors.textPrimary,
							),
						),
					),
				),
				SizedBox(
					width: 40,
					height: 40,
					child: IconButton(
						padding: EdgeInsets.zero,
						icon: const Icon(AppIcons.check_rounded, size: 22, color: AppColors.primary),
						onPressed: onMarkAll,
					),
				),
			],
		);
	}
}

class _SectionHeader extends StatelessWidget {
	const _SectionHeader({required this.title, this.countLabel});

	final String title;
	final String? countLabel;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Text(
					title,
					style: const TextStyle(
						fontSize: 10,
						fontWeight: FontWeight.w700,
						letterSpacing: 0.8,
						color: AppColors.textSecondary,
					),
				),
				const Spacer(),
				if (countLabel != null)
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
						decoration: BoxDecoration(
							color: const Color(0xFFEAF2FF),
							borderRadius: BorderRadius.circular(999),
						),
						child: const Text(
							'2 unread',
							style: TextStyle(
								fontSize: 9,
								fontWeight: FontWeight.w600,
								color: Color(0xFF5B86F5),
							),
						),
					),
			],
		);
	}
}

class _NotificationCard extends StatelessWidget {
	const _NotificationCard({required this.data});

	final _NotificationCardData data;

	@override
	Widget build(BuildContext context) {
		final titleColor = data.muted ? const Color(0xFF6B7280) : AppColors.textPrimary;
		final bodyColor = data.muted ? const Color(0xFF94A3B8) : AppColors.textSecondary;

		return Container(
			padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: const Color(0xFFD8E5FB)),
				boxShadow: [
					BoxShadow(
						color: const Color(0xFF2B5FBF).withAlpha(10),
						blurRadius: 16,
						offset: const Offset(0, 6),
					),
				],
			),
			child: Stack(
				children: [
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								width: 34,
								height: 34,
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									color: data.iconBackground,
								),
								child: Icon(data.icon, size: 18, color: data.iconColor),
							),
							const SizedBox(width: 10),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											data.title,
											style: TextStyle(
												fontSize: 12.5,
												fontWeight: FontWeight.w700,
												height: 1.15,
												color: titleColor,
											),
										),
										const SizedBox(height: 4),
										Text(
											data.message,
											style: TextStyle(
												fontSize: 11.2,
												height: 1.45,
												color: bodyColor,
											),
										),
										const SizedBox(height: 8),
										Text(
											data.timeLabel,
											style: const TextStyle(
												fontSize: 10,
												fontWeight: FontWeight.w500,
												color: AppColors.textSecondary,
											),
										),
									],
								),
							),
						],
					),
					if (data.showUnreadDot)
						const Positioned(
							top: 0,
							right: 0,
							child: _UnreadDot(),
						),
				],
			),
		);
	}
}

class _UnreadDot extends StatelessWidget {
	const _UnreadDot();

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 6,
			height: 6,
			decoration: const BoxDecoration(
				shape: BoxShape.circle,
				color: Color(0xFF5B86F5),
			),
		);
	}
}

class _NotificationCardData {
	const _NotificationCardData({
		required this.title,
		required this.message,
		required this.timeLabel,
		required this.icon,
		required this.iconBackground,
		required this.iconColor,
		this.showUnreadDot = false,
		this.muted = false,
	});

	final String title;
	final String message;
	final String timeLabel;
	final IconData icon;
	final Color iconBackground;
	final Color iconColor;
	final bool showUnreadDot;
	final bool muted;
}