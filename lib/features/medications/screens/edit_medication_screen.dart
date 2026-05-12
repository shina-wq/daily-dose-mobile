import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/medication_provider.dart';
import 'add_medication_screen.dart';

class EditMedicationScreen extends ConsumerWidget {
	const EditMedicationScreen({super.key, required this.medicationId});

	final String medicationId;

	@override
	Widget build(BuildContext context, WidgetRef ref) {
		final medicationAsync = ref.watch(medicationByIdProvider(medicationId));

		return Scaffold(
			body: SafeArea(
				child: medicationAsync.when(
					loading: () => const Center(child: CircularProgressIndicator()),
					error: (error, stackTrace) => Center(
						child: Padding(
							padding: const EdgeInsets.all(24),
							child: Text('Failed to load medication: $error'),
						),
					),
					data: (medication) {
						if (medication == null) {
							return const Center(child: Text('Medication not found'));
						}
						return AddMedicationScreen(
							medication: medication,
							isEditing: true,
						);
					},
				),
			),
		);
	}
}