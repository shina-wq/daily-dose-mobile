import 'package:flutter/material.dart' hide Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/token_storage.dart';
import '../../../core/providers/storage_provider.dart';
import '../../../services/auth_service.dart';
import '../providers/auth_controller.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../widgets/auth_form_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
	const LoginScreen({super.key});

	@override
	ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
	bool _obscurePassword = true;
	final _formKey = GlobalKey<FormState>();
	final TextEditingController _emailController = TextEditingController();
	final TextEditingController _passwordController = TextEditingController();

	void _goBack() {
		if (Navigator.of(context).canPop()) {
			Navigator.of(context).pop();
			return;
		}

		Navigator.of(context).pushReplacementNamed(AppRouter.landingRoute);
	}

	@override
	void dispose() {
		_emailController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	Future<void> _submit() async {
		if (!_formKey.currentState!.validate()) return;

		final email = _emailController.text.trim();
		final password = _passwordController.text;

		final dialogFuture = showDialog(
			context: context,
			barrierDismissible: false,
			builder: (_) => const Center(child: CircularProgressIndicator()),
		);

		try {
			await ref.read(authControllerProvider).loginUser(email: email, password: password);
			// persist basic user info locally
			String? uid;
			try {
				uid = AuthService.instance.currentUser?.uid;
			} catch (_) {}
			await ref.read(userStorageProvider).saveBasic(uid: uid, email: email);
			// Dismiss the loading dialog before replacing the route.
			if (mounted) {
				try {
					if (Navigator.of(context, rootNavigator: true).canPop()) {
						Navigator.of(context, rootNavigator: true).pop();
					}
				} catch (_) {}

				await dialogFuture;

				if (!mounted) {
					return;
				}

				Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
			}
		} catch (e) {
			Navigator.of(context).pop();
			ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
			return;
		}
	}

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
														'Welcome back',
														style: Theme.of(context).textTheme.headlineMedium?.copyWith(
																fontWeight: FontWeight.w800,
																fontSize: isCompact ? 22 : 24,
																height: 1.08,
														),
													),
													const SizedBox(height: 10),
													Text(
														'Log in to continue managing your health\njourney.',
														style: TextStyle(
															color: AppColors.textSecondary,
															fontSize: isCompact ? 14 : 15,
															height: 1.35,
														),
													),
													const SizedBox(height: 24),
																						AuthFormField(
																							controller: _emailController,
																							label: 'Email Address',
																							hintText: 'sarah.jenkins@example.com',
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
																							controller: _passwordController,
																							label: 'Password',
																							hintText: '........',
																							prefixIcon: Icons.lock_outline_rounded,
																							obscureText: _obscurePassword,
																							validator: (v) {
																								if (v == null || v.isEmpty) return 'Password is required';
																								return null;
																							},
																							suffixIcon: IconButton(
																								onPressed: () {
																									setState(() => _obscurePassword = !_obscurePassword);
																								},
																								icon: Icon(
																									_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
																									color: AppColors.textSecondary,
																								),
																							),
																						),
													Align(
														alignment: Alignment.centerRight,
														child: TextButton(
															onPressed: () {
																Navigator.of(context).pushNamed(AppRouter.forgotPasswordRoute);
															},
															child: const Text('Forgot password?'),
														),
													),
													const SizedBox(height: 76),
													SizedBox(
														height: AppDimensions.buttonHeight,
																												child: FilledButton(
																													onPressed: _submit,
																													style: FilledButton.styleFrom(
																														shape: RoundedRectangleBorder(
																															borderRadius: BorderRadius.circular(18),
																														),
																													),
																													child: const Text('Log In'),
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
																"Don't have an account? ",
																style: TextStyle(color: AppColors.textSecondary),
															),
															TextButton(
																onPressed: () {
																	Navigator.of(context).pushReplacementNamed(AppRouter.registerRoute);
																},
																child: const Text('Sign Up'),
															),
														],
													),
												],
											),
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
