import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../medications/models/medication_notification_model.dart';
import '../../medications/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
	const NotificationsScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final notificationsAsync = ref.watch(notificationsProvider);

		return Scaffold(
			backgroundColor: AppColors.background,
			body: SafeArea(
				bottom: false,
				child: LayoutBuilder(
					builder: (context, constraints) {
						return Center(
							child: ConstrainedBox(
								constraints: const BoxConstraints(maxWidth: 430),
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Padding(
											padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
											child: Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													const Text(
														'Notifications',
														style: TextStyle(
															fontSize: 28,
															fontWeight: FontWeight.w700,
															letterSpacing: -0.4,
															color: AppColors.textPrimary,
														),
													),
													IconButton(
														icon: const Icon(Icons.done_all, size: 24),
														onPressed: () {
															ref
																	.read(notificationActionProvider.notifier)
																	.markAllAsRead();
														},
														tooltip: 'Mark all as read',
													),
												],
											),
										),
										Expanded(
											child: notificationsAsync.when(
												data: (notifications) {
													if (notifications.isEmpty) {
														return Center(
															child: Column(
																mainAxisAlignment: MainAxisAlignment.center,
																children: [
																	Icon(
																		Icons.notifications_off_outlined,
																		size: 64,
																		color: AppColors.textSecondary.withAlpha(128),
																	),
																	const SizedBox(height: 16),
																	Text(
																		'No notifications yet',
																		style: TextStyle(
																			fontSize: 18,
																			fontWeight: FontWeight.w600,
																			color: AppColors.textSecondary,
																		),
																	),
																],
															),
														);
													}

													return ListView.builder(
														padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
														itemCount: notifications.length,
														itemBuilder: (context, index) {
															return _NotificationItem(
																notification: notifications[index],
																onDismiss: () {
																	ref
																			.read(notificationActionProvider.notifier)
																			.deleteNotification(notifications[index].id);
																},
															);
														},
													);
												},
												loading: () => const Center(
													child: CircularProgressIndicator(),
												),
												error: (err, stack) => Center(
													child: Column(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															Icon(
																Icons.error_outline,
																size: 64,
																color: const Color(0xFFEF4444).withAlpha(128),
															),
															const SizedBox(height: 16),
															Text(
																'Error loading notifications',
																style: TextStyle(
																	fontSize: 18,
																	fontWeight: FontWeight.w600,
																	color: AppColors.textSecondary,
																),
															),
														],
													),
												),
											),
										),
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

class _NotificationItem extends ConsumerWidget {
	final MedicationNotificationModel notification;
	final VoidCallback onDismiss;

	const _NotificationItem({
		required this.notification,
		required this.onDismiss,
	});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final backgroundColor = _getBackgroundColor();
		final iconColor = _getIconColor();
		final icon = _getIcon();

		return Dismissible(
			key: Key(notification.id),
			onDismissed: (_) => onDismiss(),
			background: Container(
				decoration: BoxDecoration(
					color: const Color(0xFFEF4444),
					borderRadius: BorderRadius.circular(16),
				),
				alignment: Alignment.centerRight,
				padding: const EdgeInsets.only(right: 16),
				child: const Icon(Icons.delete, color: AppColors.white),
			),
			child: GestureDetector(
				onTap: notification.isRead
					? null
					: () async {
							await ref
									.read(notificationActionProvider.notifier)
									.markAsRead(notification.id);
						},
				child: Container(
					margin: const EdgeInsets.only(bottom: 8),
					padding: const EdgeInsets.all(12),
					decoration: BoxDecoration(
						color: notification.isRead ? AppColors.white : backgroundColor,
						borderRadius: BorderRadius.circular(16),
						border: Border.all(
							color: notification.isRead
									? AppColors.border
									: iconColor.withAlpha(51),
						),
					),
					child: Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Container(
								width: 40,
								height: 40,
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									color: iconColor.withAlpha(51),
								),
								child: Icon(icon, size: 20, color: iconColor),
							),
							const SizedBox(width: 12),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											notification.title,
											style: TextStyle(
												fontSize: 14,
												fontWeight: FontWeight.w700,
												color: AppColors.textPrimary,
											),
										),
										const SizedBox(height: 4),
										Text(
											notification.message,
											style: const TextStyle(
												fontSize: 13,
												color: AppColors.textSecondary,
											),
											maxLines: 2,
											overflow: TextOverflow.ellipsis,
										),
										const SizedBox(height: 6),
										Text(
											_formatTime(notification.scheduledTime),
											style: const TextStyle(
												fontSize: 11,
												color: AppColors.textSecondary,
											),
										),
									],
								),
							),
							if (!notification.isRead)
								Padding(
									padding: const EdgeInsets.only(left: 8),
									child: Container(
										width: 8,
										height: 8,
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: iconColor,
										),
									),
								),
						],
					),
				),
			),
		);
	}

	Color _getBackgroundColor() {
		switch (notification.type) {
			case NotificationType.reminder:
				return const Color(0xFFF0F5FF);
			case NotificationType.missedDose:
				return const Color(0xFFFEF2F2);
			case NotificationType.streakWarning:
				return const Color(0xFFFFF7ED);
			case NotificationType.adherenceReport:
				return const Color(0xFFF0FDF4);
		}
	}

	Color _getIconColor() {
		switch (notification.type) {
			case NotificationType.reminder:
				return AppColors.primary;
			case NotificationType.missedDose:
				return const Color(0xFFEF4444);
			case NotificationType.streakWarning:
				return const Color(0xFFF59E0B);
			case NotificationType.adherenceReport:
				return AppColors.secondary;
		}
	}

	IconData _getIcon() {
		switch (notification.type) {
			case NotificationType.reminder:
				return Icons.schedule;
			case NotificationType.missedDose:
				return Icons.error_outline;
			case NotificationType.streakWarning:
				return Icons.warning_amber;
			case NotificationType.adherenceReport:
				return Icons.trending_up;
		}
	}

	String _formatTime(DateTime dateTime) {
		final now = DateTime.now();
		final difference = now.difference(dateTime);

		if (difference.inMinutes < 1) {
			return 'Just now';
		} else if (difference.inMinutes < 60) {
			return '${difference.inMinutes}m ago';
		} else if (difference.inHours < 24) {
			return '${difference.inHours}h ago';
		} else if (difference.inDays < 7) {
			return '${difference.inDays}d ago';
		} else {
			const monthNames = [
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
			return '${monthNames[dateTime.month - 1]} ${dateTime.day}';
		}
	}
}
