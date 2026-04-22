import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';

class AddMedicationScreen extends StatefulWidget {
	const AddMedicationScreen({super.key});

	@override
	State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _doseController = TextEditingController(text: '10');
	final TextEditingController _frequencyController = TextEditingController(text: 'Every day');

	int _selectedFormIndex = 0;
	String _selectedUnit = 'mg';
	bool _smartReminders = true;
	final List<String> _reminderTimes = ['8:00 AM'];

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
		_frequencyController.dispose();
		super.dispose();
	}

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
			return;
		}

		Navigator.of(context).pushReplacementNamed(AppRouter.medicationsRoute);
	}

	void _saveMedication() {
		Navigator.of(context).pop();
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
														onPressed: _goBack,
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
													separatorBuilder: (_, __) => const SizedBox(width: 10),
													itemBuilder: (context, index) {
														final form = _forms[index];
														final selected = index == _selectedFormIndex;
														return GestureDetector(
															onTap: () => setState(() => _selectedFormIndex = index),
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
																	value: _selectedUnit,
																	items: const [
																		DropdownMenuItem(value: 'mg', child: Text('mg')),
																		DropdownMenuItem(value: 'mcg', child: Text('mcg')),
																		DropdownMenuItem(value: 'ml', child: Text('ml')),
																	],
																	onChanged: (value) {
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
											DropdownButtonFormField<String>(
												value: _frequencyController.text,
												items: const [
													DropdownMenuItem(value: 'Every day', child: Text('Every day')),
													DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
													DropdownMenuItem(value: 'Once weekly', child: Text('Once weekly')),
												],
												onChanged: (value) {
													if (value == null) return;
													setState(() => _frequencyController.text = value);
												},
												decoration: _fieldDecoration(hintText: 'Every day'),
											),
											const SizedBox(height: 16),
											const _Label('Reminder Times'),
											const SizedBox(height: 8),
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
												decoration: BoxDecoration(
													color: AppColors.white,
													borderRadius: BorderRadius.circular(16),
													border: Border.all(color: AppColors.border),
												),
												child: Row(
													children: [
														const Icon(Icons.wb_sunny_outlined, color: Color(0xFFF59E0B), size: 20),
														const SizedBox(width: 10),
														const Expanded(
															child: Text(
																'8:00 AM',
																style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
															),
														),
														IconButton(
															onPressed: () {},
															icon: const Icon(Icons.close),
														),
													],
												),
											),
											const SizedBox(height: 8),
											OutlinedButton(
												onPressed: () {
												setState(() {
													_reminderTimes.add('12:00 PM');
												});
												},
												style: OutlinedButton.styleFrom(
													minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
													foregroundColor: AppColors.primary,
													side: const BorderSide(color: Color(0xFFD1D5DB), style: BorderStyle.solid),
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
												),
												child: const Text('+ Add another time'),
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
															onChanged: (value) => setState(() => _smartReminders = value),
															activeColor: AppColors.primary,
														),
													],
												),
											),
											const SizedBox(height: 18),
											SizedBox(
												height: AppDimensions.buttonHeight,
												child: FilledButton(
													onPressed: _saveMedication,
													style: FilledButton.styleFrom(
														shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
													),
													child: const Text('Save Medication'),
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
