import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class HealthLogScreen extends StatelessWidget {
	const HealthLogScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const AppSectionScreen(
			title: 'Health Log',
			subtitle: 'Capture symptoms, vitals, and daily health notes.',
			icon: Icons.favorite_rounded,
		);
	}
}
