import 'package:flutter/material.dart';

import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  static const _tabs = <_NavTab>[
    _NavTab(label: 'Home', icon: Icons.home_rounded),
    _NavTab(label: 'Meds', icon: Icons.medication_rounded),
    _NavTab(label: 'Visits', icon: Icons.event_note_rounded),
    _NavTab(label: 'Chat', icon: Icons.chat_bubble_outline_rounded),
    _NavTab(label: 'Profile', icon: Icons.person_rounded),
  ];

  static const _pages = <Widget>[
    DashboardScreen(),
    MedicationsScreen(),
    AppointmentsScreen(),
    AiChatScreen(),
    ProfileScreen(),
  ];

  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppDimensions.md,
            0,
            AppDimensions.md,
            AppDimensions.md,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.sm,
            vertical: AppDimensions.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = index == _currentIndex;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => setState(() => _currentIndex = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          height: 6,
                          width: 6,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Icon(
                          tab.icon,
                          size: 24,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
