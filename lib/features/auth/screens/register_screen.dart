import 'package:flutter/material.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../widgets/auth_form_field.dart';

class RegisterScreen extends StatefulWidget {
	const RegisterScreen({super.key});

	@override
	State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
	bool _obscurePassword = true;
	bool _obscureConfirmPassword = true;

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
			return;
		}

		Navigator.of(context).pushReplacementNamed(AppRouter.landingRoute);
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
															onPressed: _goBack,
															icon: const Icon(Icons.arrow_back),
														),
													),
													const SizedBox(height: 8),
													Text(
														'Create Account',
														style: Theme.of(context).textTheme.headlineMedium?.copyWith(
																fontWeight: FontWeight.w800,
																fontSize: isCompact ? 22 : 24,
																height: 1.08,
														),
													),
													const SizedBox(height: 10),
													Text(
														'Start your personalized health journey with\nDailyDose today.',
														style: TextStyle(
															color: AppColors.textSecondary,
															fontSize: isCompact ? 14 : 15,
															height: 1.35,
														),
													),
													const SizedBox(height: 24),
													const AuthFormField(
														label: 'Full Name',
														hintText: 'Sarah Jenkins',
														prefixIcon: Icons.person_outline_rounded,
													),
													const SizedBox(height: 18),
													const AuthFormField(
														label: 'Email Address',
														hintText: 'sarah@example.com',
														prefixIcon: Icons.mail_outline_rounded,
														keyboardType: TextInputType.emailAddress,
													),
													const SizedBox(height: 18),
													AuthFormField(
														label: 'Password',
														hintText: 'Create a password',
														prefixIcon: Icons.lock_outline_rounded,
														obscureText: _obscurePassword,
														suffixIcon: IconButton(
															onPressed: () {
																setState(() => _obscurePassword = !_obscurePassword);
															},
															icon: Icon(
																_obscurePassword
																	? Icons.visibility_off_outlined
																	: Icons.visibility_outlined,
																color: AppColors.textSecondary,
															),
														),
													),
													const SizedBox(height: 18),
													AuthFormField(
														label: 'Confirm Password',
														hintText: 'Confirm your password',
														prefixIcon: Icons.lock_outline_rounded,
														obscureText: _obscureConfirmPassword,
														suffixIcon: IconButton(
															onPressed: () {
																setState(() =>
																		_obscureConfirmPassword = !_obscureConfirmPassword);
															},
															icon: Icon(
																_obscureConfirmPassword
																	? Icons.visibility_off_outlined
																	: Icons.visibility_outlined,
																color: AppColors.textSecondary,
															),
														),
													),
													const SizedBox(height: 8),
													const Text(
														'Must be at least 8 characters long.',
														style: TextStyle(
															fontSize: 13,
															color: AppColors.textSecondary,
														),
													),
													const SizedBox(height: 76),
													SizedBox(
														height: AppDimensions.buttonHeight,
														child: FilledButton(
															onPressed: () {
																Navigator.of(context).pushReplacementNamed(AppRouter.onboardingRoute);
															},
															style: FilledButton.styleFrom(
																shape: RoundedRectangleBorder(
																	borderRadius: BorderRadius.circular(18),
																),
															),
															child: const Text('Create Account'),
														),
													),
													const SizedBox(height: 14),
													Row(
														mainAxisAlignment: MainAxisAlignment.center,
														children: [
															const Text(
																'Already have an account? ',
																style: TextStyle(color: AppColors.textSecondary),
															),
															TextButton(
																onPressed: () {
																	Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
																},
																child: const Text('Log In'),
															),
														],
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
