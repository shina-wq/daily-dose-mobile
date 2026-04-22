import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';

class MedicationsScreen extends StatelessWidget {
	const MedicationsScreen({super.key});

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
										children: [
											Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: [
													const Text(
														'Medications',
														style: TextStyle(
															fontSize: 28,
															fontWeight: FontWeight.w700,
															letterSpacing: -0.4,
															color: AppColors.textPrimary,
														),
													),
													InkWell(
														borderRadius: BorderRadius.circular(999),
														onTap: () {
															Navigator.of(context).pushNamed(AppRouter.addMedicationRoute);
														},
														child: Container(
															width: 34,
															height: 34,
															decoration: BoxDecoration(
																shape: BoxShape.circle,
																border: Border.all(color: AppColors.border),
																color: AppColors.white,
															),
															child: const Icon(
																Icons.add,
																size: 20,
																color: AppColors.primary,
															),
														),
													),
												],
											),
											const SizedBox(height: 16),
											Container(
												padding: const EdgeInsets.all(14),
												decoration: BoxDecoration(
													color: AppColors.white,
													borderRadius: BorderRadius.circular(18),
													border: Border.all(color: AppColors.border),
												),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															children: const [
																Text(
																	'Weekly Adherence',
																	style: TextStyle(
																		fontSize: 13,
																		fontWeight: FontWeight.w700,
																		color: AppColors.textPrimary,
																	),
																),
																Text(
																	'85%',
																	style: TextStyle(
																		fontSize: 13,
																		fontWeight: FontWeight.w700,
																		color: AppColors.secondary,
																	),
																),
															],
														),
														const SizedBox(height: 12),
														Row(
															mainAxisAlignment: MainAxisAlignment.spaceBetween,
															children: const [
																_AdherenceDay(label: 'M', done: true),
																_AdherenceDay(label: 'T', done: true),
																_AdherenceDay(label: 'W', done: true),
																_AdherenceDay(label: 'T', missed: true),
																_AdherenceDay(label: 'F', active: true, dayNumber: '16'),
																_AdherenceDay(label: 'S', dayNumber: '17'),
																_AdherenceDay(label: 'S', dayNumber: '18'),
															],
														),
													],
												),
											),
											const SizedBox(height: 16),
											const _MedicationGroupHeader(
												icon: Icons.wb_sunny_outlined,
												iconColor: Color(0xFFF59E0B),
												title: 'Morning',
												time: '8:00 AM',
											),
											const SizedBox(height: 10),
											const _MedicationRow(
												name: 'Levothyroxine',
												description: '50mcg • 1 pill',
												icon: Icons.check,
												iconColor: Color(0xFF6EE7B7),
												done: true,
											),
											const SizedBox(height: 16),
											const _MedicationGroupHeader(
												icon: Icons.nightlight_round,
												iconColor: Color(0xFF6366F1),
												title: 'Evening',
												time: '8:00 PM',
											),
											const SizedBox(height: 10),
											const _MedicationRow(
												name: 'Metformin',
												description: '500mg • 1 pill',
												icon: Icons.link_rounded,
												iconColor: AppColors.primary,
												selected: true,
											),
											const SizedBox(height: 10),
											const _MedicationRow(
												name: 'Vitamin D3',
												description: '2000 IU • 1 capsule',
												icon: Icons.water_drop_outlined,
												iconColor: Color(0xFF64748B),
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

class _AdherenceDay extends StatelessWidget {
	const _AdherenceDay({
		required this.label,
		this.dayNumber,
		this.done = false,
		this.missed = false,
		this.active = false,
	});

	final String label;
	final String? dayNumber;
	final bool done;
	final bool missed;
	final bool active;

	@override
	Widget build(BuildContext context) {
		final Color fillColor;
		final Widget inner;

		if (done) {
			fillColor = AppColors.secondary;
			inner = const Icon(Icons.check, size: 12, color: AppColors.white);
		} else if (missed) {
			fillColor = const Color(0xFFFFF7ED);
			inner = const Text('✕', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFF59E0B)));
		} else if (active) {
			fillColor = const Color(0xFFF5F8FF);
			inner = Text(dayNumber ?? label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary));
		} else {
			fillColor = const Color(0xFFF1F5F9);
			inner = Text(dayNumber ?? label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary));
		}

		return Column(
			children: [
				Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
				const SizedBox(height: 8),
				Container(
					width: 24,
					height: 24,
					alignment: Alignment.center,
					decoration: BoxDecoration(
						shape: BoxShape.circle,
						color: fillColor,
						border: Border.all(color: active ? AppColors.primary : Colors.transparent, width: 1.4),
					),
					child: inner,
				),
			],
		);
	}
}

class _MedicationGroupHeader extends StatelessWidget {
	const _MedicationGroupHeader({
		required this.icon,
		required this.iconColor,
		required this.title,
		required this.time,
	});

	final IconData icon;
	final Color iconColor;
	final String title;
	final String time;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Icon(icon, size: 16, color: iconColor),
				const SizedBox(width: 6),
				Expanded(
					child: Text(
						title,
						style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
					),
				),
				Text(
					time,
					style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
				),
			],
		);
	}
}

class _MedicationRow extends StatelessWidget {
	const _MedicationRow({
		required this.name,
		required this.description,
		required this.icon,
		required this.iconColor,
		this.done = false,
		this.selected = false,
	});

	final String name;
	final String description;
	final IconData icon;
	final Color iconColor;
	final bool done;
	final bool selected;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: AppColors.white,
				borderRadius: BorderRadius.circular(16),
				border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
				boxShadow: selected
						? [
							BoxShadow(
								color: AppColors.primary.withAlpha(10),
								blurRadius: 14,
								offset: const Offset(0, 6),
							),
						]
						: null,
			),
			child: Row(
				children: [
					Container(
						width: 38,
						height: 38,
						decoration: BoxDecoration(
							shape: BoxShape.circle,
							color: iconColor.withAlpha(24),
						),
						child: Icon(icon, size: 18, color: iconColor),
					),
					const SizedBox(width: 10),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									name,
									style: TextStyle(
										fontSize: 15,
										fontWeight: FontWeight.w700,
										color: done ? AppColors.textSecondary : AppColors.textPrimary,
									),
								),
								const SizedBox(height: 2),
								Text(
									description,
									style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
								),
							],
						),
					),
					Container(
						width: 24,
						height: 24,
						decoration: BoxDecoration(
							shape: BoxShape.circle,
							border: Border.all(color: selected ? AppColors.primary : AppColors.textSecondary, width: 1.5),
							color: selected ? AppColors.white : AppColors.transparent,
						),
						child: done
							? const Icon(Icons.check, size: 14, color: AppColors.secondary)
							: selected
								? const Icon(Icons.radio_button_checked, size: 14, color: AppColors.primary)
								: null,
					),
				],
			),
		);
	}
}
