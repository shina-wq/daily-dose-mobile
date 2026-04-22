import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSectionScreen(
      title: 'Profile',
      subtitle: 'Update your account, preferences, and app settings.',
      icon: Icons.person_rounded,
    );
  }
}