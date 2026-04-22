import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class AppointmentsScreen extends StatelessWidget {
	const AppointmentsScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const AppSectionScreen(
			title: 'Appointments',
			subtitle: 'Manage upcoming visits, reminders, and follow-ups.',
			icon: Icons.event_note_rounded,
		);
	}
}
