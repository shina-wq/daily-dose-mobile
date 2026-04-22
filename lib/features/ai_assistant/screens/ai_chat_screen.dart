import 'package:flutter/material.dart';

import '../../../core/widgets/app_section_screen.dart';

class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppSectionScreen(
      title: 'AI Chat',
      subtitle:
          'Ask questions about meds, symptoms, or your care plan anytime.',
      icon: Icons.smart_toy_rounded,
    );
  }
}