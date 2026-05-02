import 'package:flutter/material.dart' hide Icons;

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../services/auth_service.dart';
import '../../../services/profile_service.dart';
import '../models/profile_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();
  final _careTeamController = TextEditingController();
  final _healthLogsController = TextEditingController();

  bool _isSaving = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    _careTeamController.dispose();
    _healthLogsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign in to view your profile.',
                  style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.loginRoute,
                    (route) => false,
                  ),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: StreamBuilder<ProfileModel>(
                  stream: ProfileService.instance.watchCurrentUserProfile(),
                  builder: (context, snapshot) {
                    final profile = snapshot.data ??
                        ProfileModel.empty(
                          uid: currentUser.uid,
                          email: currentUser.email ?? '',
                        );

                    _primeControllers(profile);

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProfileHeroCard(
                            profile: profile,
                            onOpenSettings: () {},
                          ),
                          const SizedBox(height: 14),
                          const _SectionLabel('HEALTH PROFILE'),
                          const SizedBox(height: 8),
                          _InfoCard(
                            items: [
                              _InfoItem(
                                icon: AppIcons.description_outlined,
                                iconTint: const Color(0xFF10B981),
                                title: 'Personal Details',
                                subtitle: _personalDetailsSubtitle(profile),
                                onTap: _showEditProfileBottomSheet,
                              ),
                              _InfoItem(
                                icon: AppIcons.warning_amber,
                                iconTint: const Color(0xFFEF4444),
                                title: 'Conditions & Allergies',
                                subtitle: profile.conditionSummary?.isNotEmpty == true
                                    ? profile.conditionSummary!
                                    : 'Tap to add your condition summary',
                                onTap: _showEditProfileBottomSheet,
                              ),
                              _InfoItem(
                                icon: AppIcons.user_round,
                                iconTint: const Color(0xFF3B82F6),
                                title: 'Care Team',
                                subtitle: profile.careTeamSummary?.isNotEmpty == true
                                    ? profile.careTeamSummary!
                                    : 'Tap to add provider details',
                                onTap: _showEditProfileBottomSheet,
                              ),
                              _InfoItem(
                                icon: AppIcons.activity,
                                iconTint: const Color(0xFF22C55E),
                                title: 'Health Logs & History',
                                subtitle: profile.healthLogsSummary?.isNotEmpty == true
                                    ? profile.healthLogsSummary!
                                    : 'Symptoms, vitals, journals',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AppRouter.healthLogRoute),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const _SectionLabel('PREFERENCES'),
                          const SizedBox(height: 8),
                          _InfoCard(
                            items: [
                              _InfoItem(
                                icon: AppIcons.notifications_none_rounded,
                                iconTint: const Color(0xFFF59E0B),
                                title: 'Notifications',
                                subtitle: 'Reminders, alerts',
                                onTap: () => Navigator.of(context)
                                    .pushNamed(AppRouter.notificationsRoute),
                              ),
                              _InfoItem(
                                icon: AppIcons.auto_awesome,
                                iconTint: const Color(0xFF3B82F6),
                                title: 'AI Settings',
                                subtitle: 'Summaries, insights',
                                onTap: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ActionTile(
                            icon: AppIcons.help_circle,
                            label: 'Help & Support',
                            onTap: () {},
                          ),
                          const SizedBox(height: 10),
                          _ActionTile(
                            icon: AppIcons.log_out,
                            label: _isSaving ? 'Logging out...' : 'Log Out',
                            isDestructive: true,
                            onTap: _isSaving ? null : _logout,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : () => _saveProfile(profile),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _primeControllers(ProfileModel profile) {
    if (_isInitialized) {
      return;
    }

    _nameController.text = profile.name;
    _ageController.text = profile.age > 0 ? profile.age.toString() : '';
    _conditionController.text = profile.conditionSummary ?? '';
    _careTeamController.text = profile.careTeamSummary ?? '';
    _healthLogsController.text = profile.healthLogsSummary ?? '';
    _isInitialized = true;
  }

  String _personalDetailsSubtitle(ProfileModel profile) {
    if (profile.age <= 0 && (profile.gender == null || profile.gender!.isEmpty)) {
      return 'Add age and profile details';
    }

    final parts = <String>[];
    if (profile.age > 0) {
      parts.add('Age ${profile.age}');
    }
    if (profile.gender?.isNotEmpty == true) {
      parts.add(profile.gender!);
    }

    return parts.join(', ');
  }

  Future<void> _saveProfile(ProfileModel baseProfile) async {
    setState(() => _isSaving = true);

    try {
      final parsedAge = int.tryParse(_ageController.text.trim()) ?? 0;
      final updated = baseProfile.copyWith(
        name: _nameController.text.trim(),
        age: parsedAge,
        conditionSummary: _conditionController.text.trim(),
        careTeamSummary: _careTeamController.text.trim(),
        healthLogsSummary: _healthLogsController.text.trim(),
      );

      await ProfileService.instance.updateCurrentUserProfile(updated);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showEditProfileBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _SheetField(label: 'Name', controller: _nameController),
                _SheetField(
                  label: 'Age',
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                ),
                _SheetField(
                  label: 'Conditions & Allergies',
                  controller: _conditionController,
                  maxLines: 2,
                ),
                _SheetField(
                  label: 'Care Team',
                  controller: _careTeamController,
                  maxLines: 2,
                ),
                _SheetField(
                  label: 'Health Logs Summary',
                  controller: _healthLogsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    setState(() => _isSaving = true);

    try {
      await AuthService.instance.logout();

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.loginRoute,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to log out: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.profile,
    required this.onOpenSettings,
  });

  final ProfileModel profile;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF3F6FD8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              IconButton(
                onPressed: onOpenSettings,
                icon: const Icon(
                  AppIcons.settings,
                  color: AppColors.white,
                  size: 18,
                ),
                splashRadius: 18,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
              border: Border.all(color: AppColors.white, width: 3),
            ),
            alignment: Alignment.center,
            child: Text(
              _avatarText(profile.name),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            profile.name.isNotEmpty ? profile.name : 'Your Name',
            style: const TextStyle(
              fontSize: 33,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile.conditionSummary?.isNotEmpty == true
                ? profile.conditionSummary!
                : 'Managing your health journey',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFDBEAFE),
            ),
          ),
        ],
      ),
    );
  }

  static String _avatarText(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF64748B),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.items});

  final List<_InfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _InfoRow(item: items[i]),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: 58,
                endIndent: 10,
                color: Color(0xFFE5E7EB),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem({
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconTint;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.item});

  final _InfoItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: item.iconTint.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.iconTint, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              AppIcons.chevron_right,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: isDestructive ? const Color(0xFFFDECEC) : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive ? const Color(0xFFF8D3D3) : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDestructive ? const Color(0xFFEF4444) : AppColors.textPrimary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color:
                    isDestructive ? const Color(0xFFEF4444) : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
