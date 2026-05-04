import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AuthFormField extends StatelessWidget {
	const AuthFormField({
		super.key,
		required this.label,
		required this.hintText,
		required this.prefixIcon,
		this.keyboardType,
		this.obscureText = false,
		this.suffixIcon,
		this.controller,
		this.validator,
	});

	final String label;
	final String hintText;
	final IconData prefixIcon;
	final TextInputType? keyboardType;
	final bool obscureText;
	final Widget? suffixIcon;
	final TextEditingController? controller;
	final String? Function(String?)? validator;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: const TextStyle(
						fontSize: 14,
						fontWeight: FontWeight.w600,
						color: AppColors.textPrimary,
					),
				),
				const SizedBox(height: 10),
				TextFormField(
					controller: controller,
					keyboardType: keyboardType,
					obscureText: obscureText,
					validator: validator,
					decoration: InputDecoration(
						hintText: hintText,
						hintStyle: const TextStyle(color: AppColors.textSecondary),
						prefixIcon: Icon(prefixIcon, color: AppColors.textSecondary),
						suffixIcon: suffixIcon,
						fillColor: AppColors.surface,
						filled: true,
						contentPadding: const EdgeInsets.symmetric(
							horizontal: 16,
							vertical: 18,
						),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(18),
							borderSide: const BorderSide(color: AppColors.border),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(18),
							borderSide: const BorderSide(color: AppColors.border),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(18),
							borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
						),
					),
				),
			],
		);
	}
}
