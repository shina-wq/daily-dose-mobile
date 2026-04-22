import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class DashboardScreen extends StatelessWidget {
	const DashboardScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const AppSectionScreen(
			title: 'Home',
			subtitle:
					'Your daily overview, reminders, and quick actions live here.',
			icon: Icons.home_rounded,
		);
	}
}
