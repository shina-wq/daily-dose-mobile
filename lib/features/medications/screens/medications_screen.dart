import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class MedicationsScreen extends StatelessWidget {
	const MedicationsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const AppSectionScreen(
			title: 'Meds',
			subtitle: 'Track your medications, doses, and schedules in one place.',
			icon: Icons.medication_rounded,
		);
	}
}
