import 'package:flutter/material.dart' hide Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../dashboard/providers/home_provider.dart';
import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
	const AddMedicationScreen({super.key, this.medication, this.isEditing = false});

	final MedicationModel? medication;
	final bool isEditing;

	@override
	ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _doseController = TextEditingController(text: '10');
	late final TextEditingController _frequencyController;
	final TextEditingController _reasonController = TextEditingController();
	final TextEditingController _notesController = TextEditingController();

	int _selectedFormIndex = 0;
	String _selectedUnit = 'mg';
	bool _smartReminders = true;
	late List<String> _reminderTimes;
	bool _isLoading = false;

	bool get _isEditing => widget.isEditing;

	final List<_FormChoice> _forms = [
		_FormChoice(icon: AppIcons.medication_outlined, label: 'Pill'),
		_FormChoice(icon: AppIcons.circle_outlined, label: 'Capsule'),
		_FormChoice(icon: AppIcons.water_drop_outlined, label: 'Liquid'),
		_FormChoice(icon: AppIcons.medical_services_outlined, label: 'Inject'),
	];

	@override
	void initState() {
		super.initState();
		final medication = widget.medication;
		_reminderTimes = medication?.timeSlots.isNotEmpty == true ? List<String>.from(medication!.timeSlots) : ['08:00'];
		_frequencyController = TextEditingController(text: medication?.frequency ?? _defaultFrequencyForTimes(_reminderTimes));
		if (medication != null) {
			_nameController.text = medication.name;
			_doseController.text = _extractDoseValue(medication.dosage);
			_selectedUnit = _extractDoseUnit(medication.dosage);
			_reasonController.text = medication.reason ?? '';
			_notesController.text = medication.notes ?? '';
			_selectedFormIndex = _formIndexFromMedication(medication);
		}
	}

	@override
	void dispose() {
		_nameController.dispose();
		_doseController.dispose();
		_frequencyController.dispose();
		_reasonController.dispose();
		_notesController.dispose();
		super.dispose();
	}

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
			return;
		}
		Navigator.of(context).pushReplacementNamed(AppRouter.medicationsRoute);
	}

	Future<void> _saveMedication() async {
		if (_nameController.text.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please enter medication name')),
			);
			return;
		}

		if (_frequencyController.text.trim().isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please enter a frequency')),
			);
			return;
		}

		if (_reminderTimes.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please add at least one reminder time')),
			);
			return;
		}

		setState(() => _isLoading = true);

		try {
			final dosage = '${_doseController.text}$_selectedUnit';
			final frequency = _frequencyController.text.trim().isEmpty
				? _defaultFrequencyForTimes(_reminderTimes)
				: _frequencyController.text.trim();

			final auth = ref.read(authStateProvider);
			final uid = auth.asData?.value?.uid;
			if (uid == null) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('You must be signed in to add a medication')),
				);
				return;
			}

			final medication = MedicationModel(
				id: widget.medication?.id ?? const Uuid().v4(),
				uid: uid,
				name: _nameController.text,
				dosage: dosage,
				frequency: frequency,
				timeSlots: _reminderTimes,
				reason: _reasonController.text.isEmpty ? null : _reasonController.text,
				notes: _notesController.text.isEmpty ? null : _notesController.text,
				startDate: widget.medication?.startDate ?? DateTime.now(),
				endDate: widget.medication?.endDate,
				isActive: widget.medication?.isActive ?? true,
				sideEffects: widget.medication?.sideEffects ?? const [],
				prescribedBy: widget.medication?.prescribedBy,
				createdAt: widget.medication?.createdAt ?? DateTime.now(),
				updatedAt: widget.isEditing ? DateTime.now() : null,
			);

			if (_isEditing) {
				await ref.read(updateMedicationProvider(medication).future);
			} else {
				await ref.read(createMedicationProvider(medication).future);
			}

						// Refresh medication-related queries so the previous screen shows new data.
						if (mounted) {
							ref.invalidate(todaysDosesProvider);
							ref.invalidate(medicationsProvider);
							ref.invalidate(activeMedicationsProvider);
							ref.invalidate(overallAdherenceProvider);
							  ref.invalidate(weeklyAdherenceProvider);
							ref.invalidate(pendingDosesProvider);
							ref.invalidate(homeDashboardProvider);

							ScaffoldMessenger.of(context).showSnackBar(
								SnackBar(content: Text(_isEditing ? 'Medication updated successfully' : 'Medication saved successfully')),
							);
							Navigator.of(context).pop();
						}
            
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					SnackBar(content: Text('Error: $e')),
				);
			}
		} finally {
			if (mounted) {
				setState(() => _isLoading = false);
			}
		}
	}

	Future<void> _deleteMedication() async {
		final confirm = await showDialog<bool>(
			context: context,
			builder: (ctx) => AlertDialog(
				title: const Text('Delete medication'),
				content: const Text('This will delete the medication and all related doses. Continue?'),
				actions: [
					TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
					TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
				],
			),
		);

		if (confirm != true) return;

		setState(() => _isLoading = true);
		try {
			final medicationId = widget.medication?.id;
			if (medicationId == null) return;
			await ref.read(deleteMedicationProvider(medicationId).future);
			if (mounted) {
				ref.invalidate(todaysDosesProvider);
				ref.invalidate(medicationsProvider);
				ref.invalidate(activeMedicationsProvider);
				ref.invalidate(overallAdherenceProvider);
				ref.invalidate(weeklyAdherenceProvider);
				ref.invalidate(pendingDosesProvider);
				ref.invalidate(homeDashboardProvider);
				ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medication deleted')));
				Navigator.of(context).pop();
			}
		} catch (e) {
			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
			}
		} finally {
			if (mounted) setState(() => _isLoading = false);
		}
	}

	void _addReminderTime() {
		showTimePicker(
			context: context,
			initialTime: TimeOfDay.now(),
		).then((time) {
			if (time != null) {
				final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
				setState(() {
					if (!_reminderTimes.contains(timeStr)) {
						_reminderTimes.add(timeStr);
						_reminderTimes.sort();
					}
				});
			}
		});
	}

	void _removeReminderTime(String time) {
		setState(() => _reminderTimes.remove(time));
	}

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
									padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Row(
												children: [
													IconButton(
														onPressed: _isLoading ? null : _goBack,
														icon: const Icon(AppIcons.arrow_back),
													),
													const SizedBox(width: 4),
													Text(
														_isEditing ? 'Edit Medication' : 'Add Medication',
														style: TextStyle(
															fontSize: 21,
															fontWeight: FontWeight.w700,
															letterSpacing: -0.2,
															color: AppColors.textPrimary,
														),
													),
												],
											),
											const SizedBox(height: 16),
											const _Label('Medication Name'),
											const SizedBox(height: 8),
											TextField(
												controller: _nameController,
												enabled: !_isLoading,
												decoration: _fieldDecoration(
													hintText: 'e.g., Lisinopril',
													prefixIcon: AppIcons.search,
												),
											),
											const SizedBox(height: 18),
											const _Label('Form'),
											const SizedBox(height: 10),
											SizedBox(
												height: 84,
												child: ListView.separated(
													scrollDirection: Axis.horizontal,
													itemCount: _forms.length,
													separatorBuilder: (context, index) => const SizedBox(width: 10),
													itemBuilder: (context, index) {
														final form = _forms[index];
														final selected = index == _selectedFormIndex;
														return GestureDetector(
															onTap: _isLoading
																? null
																: () => setState(() => _selectedFormIndex = index),
															child: Container(
																width: 76,
																decoration: BoxDecoration(
																	color: selected ? const Color(0xFFF0F5FF) : AppColors.white,
																	borderRadius: BorderRadius.circular(16),
																	border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
																),
																child: Column(
																	mainAxisAlignment: MainAxisAlignment.center,
																	children: [
																		Icon(form.icon, size: 22, color: selected ? AppColors.primary : AppColors.textSecondary),
																		const SizedBox(height: 6),
																		Text(
																			form.label,
																			style: TextStyle(
																				fontSize: 13,
																				fontWeight: FontWeight.w600,
																				color: selected ? AppColors.primary : AppColors.textPrimary,
																			),
																		),
																	],
																),
															),
														);
													},
												),
											),
											const SizedBox(height: 16),
											Row(
												children: [
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const _Label('Dose'),
																const SizedBox(height: 8),
																TextField(
																	controller: _doseController,
																	enabled: !_isLoading,
																	keyboardType: TextInputType.number,
																	decoration: _fieldDecoration(hintText: '10'),
																),
															],
														),
													),
													const SizedBox(width: 12),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const _Label('Unit'),
																const SizedBox(height: 8),
																DropdownButtonFormField<String>(
																	initialValue: _selectedUnit,
																	items: const [
																		DropdownMenuItem(value: 'mg', child: Text('mg')),
																		DropdownMenuItem(value: 'mcg', child: Text('mcg')),
																		DropdownMenuItem(value: 'ml', child: Text('ml')),
																	],
																	onChanged: _isLoading
																		? null
																		: (value) {
																			if (value == null) return;
																			setState(() => _selectedUnit = value);
																		},
																	decoration: _fieldDecoration(hintText: 'mg'),
																),
															],
														),
													),
												],
											),
											const SizedBox(height: 16),
											const _Label('Frequency'),
											const SizedBox(height: 8),
											TextField(
												controller: _frequencyController,
												enabled: !_isLoading,
												decoration: _fieldDecoration(hintText: 'e.g., once daily'),
											),
											const SizedBox(height: 16),
											const _Label('Reason (Optional)'),
											const SizedBox(height: 8),
											TextField(
												controller: _reasonController,
												enabled: !_isLoading,
												decoration: _fieldDecoration(
													hintText: 'e.g., Blood pressure management',
												),
											),
											const SizedBox(height: 16),
											const _Label('Reminder Times'),
											const SizedBox(height: 8),
											..._reminderTimes.map((time) {
												final hour = int.parse(time.split(':')[0]);
												return Padding(
													padding: const EdgeInsets.only(bottom: 8),
													child: Container(
														padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
														decoration: BoxDecoration(
															color: AppColors.white,
															borderRadius: BorderRadius.circular(16),
															border: Border.all(color: AppColors.border),
														),
														child: Row(
															children: [
																Icon(
																	_getTimeIcon(hour),
																	color: _getTimeColor(hour),
																	size: 20,
																),
																const SizedBox(width: 10),
																Expanded(
																	child: Text(
																		_formatTime(time),
																		style: const TextStyle(
																			fontSize: 16,
																			fontWeight: FontWeight.w600,
																		),
																	),
																),
																IconButton(
																	onPressed: _isLoading
																		? null
																		: () => _removeReminderTime(time),
																icon: const Icon(AppIcons.close),
																	iconSize: 20,
																),
															],
														),
													),
												);
											}),
											const SizedBox(height: 8),
											OutlinedButton(
												onPressed: _isLoading ? null : _addReminderTime,
												style: OutlinedButton.styleFrom(
													minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
													foregroundColor: AppColors.primary,
													side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
												),
												child: const Text('+ Add another time'),
											),
											const SizedBox(height: 16),
											const _Label('Notes (Optional)'),
											const SizedBox(height: 8),
											TextField(
												controller: _notesController,
												enabled: !_isLoading,
												maxLines: 3,
												decoration: _fieldDecoration(
													hintText: 'Add any notes about this medication...',
												),
											),
											const SizedBox(height: 16),
											Container(
												padding: const EdgeInsets.all(14),
												decoration: BoxDecoration(
													color: AppColors.white,
													borderRadius: BorderRadius.circular(18),
													border: Border.all(color: AppColors.border),
												),
												child: Row(
													children: [
														Expanded(
															child: Column(
																crossAxisAlignment: CrossAxisAlignment.start,
																children: const [
																	Text(
																		'Smart Reminders',
																		style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
																	),
																	SizedBox(height: 2),
																	Text(
																		'Adjust timing based on daily habits',
																		style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
																	),
																],
															),
														),
														Switch.adaptive(
															value: _smartReminders,
															onChanged: _isLoading
																? null
																: (value) => setState(() => _smartReminders = value),
															activeThumbColor: AppColors.primary,
														),
													],
												),
											),
											const SizedBox(height: 18),
											SizedBox(
												height: AppDimensions.buttonHeight,
												child: FilledButton(
													onPressed: _isLoading ? null : _saveMedication,
													style: FilledButton.styleFrom(
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(18),
														),
													),
													child: _isLoading
														? const SizedBox(
																width: 20,
																height: 20,
																child: CircularProgressIndicator(strokeWidth: 2),
															)
														: Text(_isEditing ? 'Save Changes' : 'Save Medication'),
												),
											),
												if (_isEditing) ...[
													const SizedBox(height: 12),
													SizedBox(
														height: AppDimensions.buttonHeight,
														child: OutlinedButton(
															onPressed: _isLoading ? null : _deleteMedication,
															style: OutlinedButton.styleFrom(
																foregroundColor: const Color(0xFFEF4444),
																side: const BorderSide(color: Color(0xFFFECACA)),
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(18),
																),
															),
															child: const Text('Delete Medication'),
														),
													),
												],
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

	InputDecoration _fieldDecoration({
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

	String _formatTime(String timeStr) {
		final parts = timeStr.split(':');
		final hour = int.parse(parts[0]);
		final minute = parts[1];
		final period = hour >= 12 ? 'PM' : 'AM';
		final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
		return '$displayHour:$minute $period';
	}

	String _defaultFrequencyForTimes(List<String> times) {
		if (times.length == 1) return 'once daily';
		if (times.length == 2) return 'twice daily';
		return '${times.length} times daily';
	}

	String _extractDoseValue(String dosage) {
		final match = RegExp(r'^\d+(?:\.\d+)?').firstMatch(dosage);
		return match?.group(0) ?? '10';
	}

	String _extractDoseUnit(String dosage) {
		final match = RegExp(r'^\d+(?:\.\d+)?\s*(.*)$').firstMatch(dosage.trim());
		final unit = match?.group(1)?.trim();
		return (unit == null || unit.isEmpty) ? 'mg' : unit;
	}

	int _formIndexFromMedication(MedicationModel medication) {
		final name = medication.name.toLowerCase();
		final dosage = medication.dosage.toLowerCase();
		if (name.contains('inject') || dosage.contains('inject')) return 3;
		if (name.contains('liquid') || dosage.contains('ml')) return 2;
		if (name.contains('capsule')) return 1;
		return 0;
	}

	IconData _getTimeIcon(int hour) {
		if (hour >= 5 && hour < 12) return AppIcons.wb_sunny_outlined;
		if (hour >= 12 && hour < 17) return AppIcons.cloud_queue_outlined;
		if (hour >= 17 && hour < 21) return AppIcons.nights_stay;
		return AppIcons.nightlight_round;
	}

	Color _getTimeColor(int hour) {
		if (hour >= 5 && hour < 12) return const Color(0xFFF59E0B);
		if (hour >= 12 && hour < 17) return const Color(0xFFF97316);
		if (hour >= 17 && hour < 21) return const Color(0xFF6366F1);
		return const Color(0xFF64748B);
	}
}



class _Label extends StatelessWidget {
	const _Label(this.text);

	final String text;

	@override
	Widget build(BuildContext context) {
		return Text(
			text,
			style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
		);
	}
}

class _FormChoice {
	const _FormChoice({required this.icon, required this.label});

	final IconData icon;
	final String label;
}
