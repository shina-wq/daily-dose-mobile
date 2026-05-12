import 'package:flutter/material.dart';

import '../../features/ai_assistant/screens/ai_chat_screen.dart';
import '../../features/appointments/screens/appointments_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/medications/screens/medications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../theme/app_icons.dart';
import '../theme/app_colors.dart';

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  static const _tabs = <_NavTab>[
    _NavTab(label: 'Home', icon: AppIcons.home_rounded),
    _NavTab(label: 'Meds', icon: AppIcons.medication_rounded),
    _NavTab(label: 'Visits', icon: AppIcons.event_note_rounded),
    _NavTab(label: 'Chat', icon: AppIcons.chat_bubble_outline_rounded),
    _NavTab(label: 'Profile', icon: AppIcons.person_rounded),
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
      body: _buildCurrentPage(),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = index == _currentIndex;

              return Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => _currentIndex = index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tab.icon,
                          size: 22,
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
                            fontSize: 10,
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

  Widget _buildCurrentPage() {
    switch (_currentIndex) {
      case 0:
        return const DashboardScreen();
      case 1:
        return const MedicationsScreen();
      case 2:
        return const AppointmentsScreen();
      case 3:
        return const AiChatScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }
}

class _NavTab {
  const _NavTab({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
