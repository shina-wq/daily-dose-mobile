import 'package:flutter/material.dart' hide Icons;

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../widgets/auth_form_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F5FA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 34),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => _goBack(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Forgot Password',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: isCompact ? 22 : 24,
                                  height: 1.08,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Enter your email and we will send\nyou a reset link.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: isCompact ? 14 : 15,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const AuthFormField(
                            label: 'Email Address',
                            hintText: 'sarah.jenkins@example.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: AppDimensions.buttonHeight,
                            child: FilledButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Password reset link sent.'),
                                  ),
                                );
                                Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
                              },
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text('Send Reset Link'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
                              },
                              child: const Text('Back to Log In'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
