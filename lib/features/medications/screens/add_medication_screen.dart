import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../models/medication_model.dart';
import '../providers/medication_provider.dart';

class AddMedicationScreen extends ConsumerStatefulWidget {
	const AddMedicationScreen({super.key});

	@override
	ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _doseController = TextEditingController(text: '10');
	final TextEditingController _reasonController = TextEditingController();
	final TextEditingController _notesController = TextEditingController();

	int _selectedFormIndex = 0;
	String _selectedUnit = 'mg';
	bool _smartReminders = true;
	final List<String> _reminderTimes = ['08:00'];
	bool _isLoading = false;

	final List<_FormChoice> _forms = [
		_FormChoice(icon: Icons.medication_outlined, label: 'Pill'),
		_FormChoice(icon: Icons.circle_outlined, label: 'Capsule'),
		_FormChoice(icon: Icons.water_drop_outlined, label: 'Liquid'),
		_FormChoice(icon: Icons.medical_services_outlined, label: 'Inject'),
	];

	@override
	void dispose() {
		_nameController.dispose();
		_doseController.dispose();
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

		if (_reminderTimes.isEmpty) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(content: Text('Please add at least one reminder time')),
			);
			return;
		}

		setState(() => _isLoading = true);

		try {
			final dosage = '${_doseController.text}$_selectedUnit';

			// Determine frequency from reminder times
			String frequency = 'once daily';
			if (_reminderTimes.length == 2) {
				frequency = 'twice daily';
			} else if (_reminderTimes.length >= 3) {
				frequency = '${_reminderTimes.length} times daily';
			}

			final auth = ref.read(authStateProvider);
			final uid = auth.asData?.value?.uid;
			if (uid == null) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('You must be signed in to add a medication')),
				);
				return;
			}

			final medication = MedicationModel(
				id: const Uuid().v4(),
				uid: uid,
				name: _nameController.text,
				dosage: dosage,
				frequency: frequency,
				timeSlots: _reminderTimes,
				reason: _reasonController.text.isEmpty ? null : _reasonController.text,
				notes: _notesController.text.isEmpty ? null : _notesController.text,
				startDate: DateTime.now(),
				createdAt: DateTime.now(),
			);

			// Trigger the create action provider
			await ref.read(createMedicationProvider(medication).future);

			if (mounted) {
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(content: Text('Medication saved successfully')),
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
														icon: const Icon(Icons.arrow_back),
													),
													const SizedBox(width: 4),
													const Text(
														'Add Medication',
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
													prefixIcon: Icons.search,
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
																	icon: const Icon(Icons.close),
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
														: const Text('Save Medication'),
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
