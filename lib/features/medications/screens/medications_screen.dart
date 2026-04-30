import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../models/medication_dose_model.dart';
import '../providers/medication_provider.dart';

class MedicationsScreen extends ConsumerWidget {
	const MedicationsScreen({super.key});

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final todaysDoses = ref.watch(todaysDosesProvider);
		final overallAdherence = ref.watch(overallAdherenceProvider);

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
											// Weekly Adherence Card
											overallAdherence.when(
												data: (adherence) => _buildAdherenceCard(adherence),
												loading: () => const SizedBox(
													height: 120,
													child: Center(child: CircularProgressIndicator()),
												),
												error: (err, stack) => Container(
													padding: const EdgeInsets.all(14),
													decoration: BoxDecoration(
														color: AppColors.white,
														borderRadius: BorderRadius.circular(18),
														border: Border.all(color: AppColors.border),
													),
													child: const Text('Unable to load adherence data'),
												),
											),
											const SizedBox(height: 16),
											// Today's Medications grouped by time
											todaysDoses.when(
												data: (doses) => _buildMedicationsList(doses),
												loading: () => const SizedBox(
													height: 200,
													child: Center(child: CircularProgressIndicator()),
												),
												error: (err, stack) => Padding(
													padding: const EdgeInsets.all(16),
													child: Text('Error loading medications: $err'),
												),
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

	Widget _buildAdherenceCard(double adherence) {
		return Container(
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
						children: [
							const Text(
								'Overall Adherence',
								style: TextStyle(
									fontSize: 13,
									fontWeight: FontWeight.w700,
									color: AppColors.textPrimary,
								),
							),
							Text(
								'${adherence.toStringAsFixed(0)}%',
								style: const TextStyle(
									fontSize: 13,
									fontWeight: FontWeight.w700,
									color: AppColors.secondary,
								),
							),
						],
					),
					const SizedBox(height: 12),
					ClipRRect(
						borderRadius: BorderRadius.circular(8),
						child: LinearProgressIndicator(
							value: adherence / 100,
							minHeight: 8,
							backgroundColor: const Color(0xFFF1F5F9),
							valueColor: AlwaysStoppedAnimation<Color>(
								adherence >= 75 ? AppColors.secondary : Color(0xFFF59E0B),
							),
						),
					),
				],
			),
		);
	}

	Widget _buildMedicationsList(List<MedicationDoseModel> doses) {
		if (doses.isEmpty) {
			return Padding(
				padding: const EdgeInsets.all(16),
				child: Text(
					'No medications scheduled for today',
					style: TextStyle(
						fontSize: 14,
						color: AppColors.textSecondary,
					),
				),
			);
		}

		// Group doses by time slot
		final Map<String, List<MedicationDoseModel>> groupedByTime = {};
		for (final dose in doses) {
			final timeStr = '${dose.scheduledTime.hour.toString().padLeft(2, '0')}:${dose.scheduledTime.minute.toString().padLeft(2, '0')}';
			groupedByTime.putIfAbsent(timeStr, () => []).add(dose);
		}

		final widgets = <Widget>[];
		groupedByTime.forEach((time, timeSlotDoses) {
			widgets.add(
				_MedicationGroupHeader(
					icon: _getTimeIcon(timeSlotDoses.first.scheduledTime.hour),
					iconColor: _getTimeColor(timeSlotDoses.first.scheduledTime.hour),
					title: _getTimeLabel(timeSlotDoses.first.scheduledTime.hour),
					time: time,
				),
			);
			widgets.add(const SizedBox(height: 10));

			for (int i = 0; i < timeSlotDoses.length; i++) {
				final dose = timeSlotDoses[i];
				widgets.add(
					_MedicationRowWithDose(
						dose: dose,
					),
				);
				if (i < timeSlotDoses.length - 1) {
					widgets.add(const SizedBox(height: 10));
				}
			}

			widgets.add(const SizedBox(height: 16));
		});

		return Column(children: widgets);
	}

	IconData _getTimeIcon(int hour) {
		if (hour >= 5 && hour < 12) return Icons.wb_sunny_outlined;
		if (hour >= 12 && hour < 17) return Icons.cloud_queue_outlined;
		if (hour >= 17 && hour < 21) return Icons.nights_stay;
		return Icons.nightlight_round;
	}

	Color _getTimeColor(int hour) {
		if (hour >= 5 && hour < 12) return const Color(0xFFF59E0B);
		if (hour >= 12 && hour < 17) return const Color(0xFFF97316);
		if (hour >= 17 && hour < 21) return const Color(0xFF6366F1);
		return const Color(0xFF64748B);
	}

	String _getTimeLabel(int hour) {
		if (hour >= 5 && hour < 12) return 'Morning';
		if (hour >= 12 && hour < 17) return 'Afternoon';
		if (hour >= 17 && hour < 21) return 'Evening';
		return 'Night';
	}
}

/// Widget to display a medication dose row with interactive status
class _MedicationRowWithDose extends ConsumerWidget {
	const _MedicationRowWithDose({
		required this.dose,
	});

	final MedicationDoseModel dose;

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final isDone = dose.status == DoseStatus.taken;
		final isLate = dose.status == DoseStatus.late;
		final isMissed = dose.status == DoseStatus.missed;
		final isPending = dose.status == DoseStatus.pending;

		return GestureDetector(
			onTap: isPending
				? () async {
						showModalBottomSheet(
							context: context,
							shape: const RoundedRectangleBorder(
								borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
							),
							builder: (context) => _DoseActionBottomSheet(dose: dose),
						);
					}
				: null,
			child: Container(
				padding: const EdgeInsets.all(12),
				decoration: BoxDecoration(
					color: AppColors.white,
					borderRadius: BorderRadius.circular(16),
					border: Border.all(
						color: isPending ? AppColors.primary : AppColors.border,
						width: isPending ? 1.5 : 1,
					),
					boxShadow: isPending
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
								color: _getStatusColor(dose.status).withAlpha(24),
							),
							child: Icon(
								_getStatusIcon(dose.status),
								size: 18,
								color: _getStatusColor(dose.status),
							),
						),
						const SizedBox(width: 10),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										dose.medicationName,
										style: TextStyle(
											fontSize: 15,
											fontWeight: FontWeight.w700,
											color: isDone || isMissed
													? AppColors.textSecondary
													: AppColors.textPrimary,
										),
									),
									const SizedBox(height: 2),
									Text(
										dose.dosage,
										style: const TextStyle(
											fontSize: 13,
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
									color: _getStatusColor(dose.status),
									width: 1.5,
								),
								color: isDone || isLate || isMissed
										? _getStatusColor(dose.status)
										: AppColors.white,
							),
							child: isDone || isLate
									? const Icon(Icons.check, size: 14, color: AppColors.white)
									: isMissed
										? const Icon(Icons.close, size: 14, color: AppColors.white)
										: null,
						),
					],
				),
			),
		);
	}

	IconData _getStatusIcon(DoseStatus status) {
		switch (status) {
			case DoseStatus.taken:
				return Icons.check_circle;
			case DoseStatus.late:
				return Icons.schedule;
			case DoseStatus.missed:
				return Icons.close;
			case DoseStatus.pending:
				return Icons.schedule;
		}
	}

	Color _getStatusColor(DoseStatus status) {
		switch (status) {
			case DoseStatus.taken:
				return AppColors.secondary;
			case DoseStatus.late:
				return const Color(0xFFF59E0B);
			case DoseStatus.missed:
				return const Color(0xFFEF4444);
			case DoseStatus.pending:
				return AppColors.primary;
		}
	}
}

/// Bottom sheet for dose actions
class _DoseActionBottomSheet extends ConsumerWidget {
	const _DoseActionBottomSheet({
		required this.dose,
	});

	final MedicationDoseModel dose;

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		return Container(
			padding: const EdgeInsets.all(20),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'${dose.medicationName} - ${dose.dosage}',
						style: const TextStyle(
							fontSize: 18,
							fontWeight: FontWeight.w700,
							color: AppColors.textPrimary,
						),
					),
					const SizedBox(height: 8),
					Text(
						'Scheduled at ${dose.scheduledTime.hour.toString().padLeft(2, '0')}:${dose.scheduledTime.minute.toString().padLeft(2, '0')}',
						style: const TextStyle(
							fontSize: 14,
							color: AppColors.textSecondary,
						),
					),
					const SizedBox(height: 24),
					SizedBox(
						width: double.infinity,
						child: FilledButton(
							onPressed: () async {
								await ref.read(markDoseTakenProvider(dose.id).future);
								if (context.mounted) Navigator.of(context).pop();
							},
							child: const Text('Mark as Taken'),
						),
					),
					const SizedBox(height: 12),
					SizedBox(
						width: double.infinity,
						child: OutlinedButton(
							onPressed: () async {
								await ref.read(markDoseMissedProvider(dose.id).future);
								if (context.mounted) Navigator.of(context).pop();
							},
							child: const Text('Mark as Missed'),
						),
					),
				],
			),
		);
	}
}

// ==================== HELPER WIDGETS ====================

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


