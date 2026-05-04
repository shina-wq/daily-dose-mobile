import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TypingIndicator extends StatefulWidget {
	const TypingIndicator({super.key, this.alignment = Alignment.centerLeft});

	final Alignment alignment;

	@override
	State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
		with SingleTickerProviderStateMixin {
	late final AnimationController _controller;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(
			duration: const Duration(milliseconds: 900),
			vsync: this,
		)..repeat();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Align(
			alignment: widget.alignment,
			child: Container(
				padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
				decoration: BoxDecoration(
					color: AppColors.white,
					borderRadius: BorderRadius.circular(14),
					border: Border.all(color: AppColors.border),
				),
				child: Row(
					mainAxisSize: MainAxisSize.min,
					children: [
						_Dot(animation: _dotAnimation(0.0, 0.35)),
						const SizedBox(width: 4),
						_Dot(animation: _dotAnimation(0.2, 0.55)),
						const SizedBox(width: 4),
						_Dot(animation: _dotAnimation(0.4, 0.75)),
					],
				),
			),
		);
	}

	Animation<double> _dotAnimation(double start, double end) {
		return Tween<double>(begin: 0, end: 1).animate(
			CurvedAnimation(
				parent: _controller,
				curve: Interval(start, end, curve: Curves.easeInOut),
			),
		);
	}
}

class _Dot extends StatelessWidget {
	const _Dot({required this.animation});

	final Animation<double> animation;

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: animation,
			builder: (context, child) {
				final scale = 0.7 + (animation.value * 0.5);
				return Transform.translate(
					offset: Offset(0, -animation.value * 4),
					child: Transform.scale(
						scale: scale,
						child: Container(
							width: 6,
							height: 6,
							decoration: const BoxDecoration(
								shape: BoxShape.circle,
								color: AppColors.textSecondary,
							),
						),
					),
				);
			},
		);
	}
}
