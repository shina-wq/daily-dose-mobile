import 'package:flutter/material.dart' hide Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_controller.dart';
import '../../../core/utils/token_storage.dart';
import '../../../core/providers/storage_provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../widgets/auth_form_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
	const RegisterScreen({super.key});

	@override
	ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
	bool _obscurePassword = true;
	bool _obscureConfirmPassword = true;
	final _formKey = GlobalKey<FormState>();
	final TextEditingController _nameController = TextEditingController();
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();
	final TextEditingController _confirmController = TextEditingController();
	final TextEditingController _ageController = TextEditingController();

	@override
	void dispose() {
		_nameController.dispose();
		_emailController.dispose();
		_passwordController.dispose();
		_confirmController.dispose();
		_ageController.dispose();
		super.dispose();
	}

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
											child: Form(
												key: _formKey,
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
																										AuthFormField(
																												controller: _nameController,
																												label: 'Full Name',
																												hintText: 'Sarah Jenkins',
																												prefixIcon: Icons.person_outline_rounded,
																												validator: (v) {
																													if (v == null || v.isEmpty) return 'Name is required';
																													return null;
																												},
																										),
																										const SizedBox(height: 18),
																										AuthFormField(
																												controller: _emailController,
																												label: 'Email Address',
																												hintText: 'sarah@example.com',
																												prefixIcon: Icons.mail_outline_rounded,
																												keyboardType: TextInputType.emailAddress,
																												validator: (v) {
																													if (v == null || v.isEmpty) return 'Email is required';
																													final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[a-zA-Z]{2,4}");
																													if (!emailRegex.hasMatch(v)) return 'Enter a valid email';
																													return null;
																												},
																										),
																										const SizedBox(height: 18),
																										AuthFormField(
																											controller: _ageController,
																											label: 'Age',
																											hintText: 'e.g. 35',
																											prefixIcon: Icons.calendar_today_outlined,
																											keyboardType: TextInputType.number,
																											validator: (v) {
																												if (v == null || v.isEmpty) return 'Age is required';
																												final n = int.tryParse(v);
																												if (n == null || n <= 0) return 'Enter a valid age';
																												return null;
																											},
																										),
																										const SizedBox(height: 18),
													AuthFormField(
														label: 'Password',
														controller: _passwordController,
														hintText: 'Create a password',
														prefixIcon: Icons.lock_outline_rounded,
														obscureText: _obscurePassword,
														validator: (v) {
															if (v == null || v.isEmpty) return 'Password is required';
															if (v.length < 8) return 'Password must be at least 8 characters';
															return null;
														},
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
														controller: _confirmController,
														hintText: 'Confirm your password',
														prefixIcon: Icons.lock_outline_rounded,
														obscureText: _obscureConfirmPassword,
														validator: (v) {
															if (v == null || v.isEmpty) return 'Confirm your password';
															if (v != _passwordController.text) return 'Passwords do not match';
															return null;
														},
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
																														onPressed: () async {
																															if (!_formKey.currentState!.validate()) return;

																															final name = _nameController.text.trim();
																															final email = _emailController.text.trim();
																															final password = _passwordController.text;
																															final age = int.tryParse(_ageController.text) ?? 0;

																															showDialog(
																																context: context,
																																barrierDismissible: false,
																																builder: (_) => const Center(child: CircularProgressIndicator()),
																															);

																															try {
																																await ref.read(authControllerProvider).registerUser(
																																	name: name,
																																	email: email,
																																	password: password,
																																	age: age,
																																);
																																await ref.read(userStorageProvider).saveBasic(email: email, name: name);
																																// Dismiss loading dialog if present (try root navigator first, then local)
																																if (mounted) {
																																	try {
																																		if (Navigator.of(context, rootNavigator: true).canPop()) {
																																			Navigator.of(context, rootNavigator: true).pop();
																																		}
																																	} catch (_) {}

																																	try {
																																		if (Navigator.of(context).canPop()) {
																																			Navigator.of(context).pop();
																																		}
																																	} catch (_) {}

																																	Navigator.of(context, rootNavigator: true).pushReplacementNamed(AppRouter.onboardingRoute);
																																}
																															} catch (e) {
																																Navigator.of(context).pop();
																																ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
																															}
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
													Wrap(
														alignment: WrapAlignment.center,
														crossAxisAlignment: WrapCrossAlignment.center,
														spacing: 0,
														runSpacing: 0,
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
						),);
					},
				),
			),
		);
	}
}
