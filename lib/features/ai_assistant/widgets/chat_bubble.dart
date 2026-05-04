import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ChatBubble extends StatelessWidget {
	const ChatBubble({
		super.key,
		required this.message,
		required this.isUser,
		this.timestamp,
		this.maxWidthFactor = 0.8,
	});

	final String message;
	final bool isUser;
	final DateTime? timestamp;
	final double maxWidthFactor;

	@override
	Widget build(BuildContext context) {
		return Align(
			alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
			child: ConstrainedBox(
				constraints: BoxConstraints(
					maxWidth: MediaQuery.of(context).size.width * maxWidthFactor,
				),
				child: Container(
					padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
					decoration: BoxDecoration(
						color: isUser ? AppColors.primary : AppColors.white,
						borderRadius: BorderRadius.circular(14),
						border: isUser ? null : Border.all(color: AppColors.border),
						boxShadow: [
							BoxShadow(
								color: Colors.black.withAlpha(8),
								blurRadius: 8,
								offset: const Offset(0, 2),
							),
						],
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment:
								isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
						children: [
							Text(
								message,
								style: TextStyle(
									fontSize: 13,
									color: isUser ? AppColors.white : AppColors.textPrimary,
									height: 1.4,
								),
							),
							if (timestamp != null) ...[
								const SizedBox(height: 6),
								Text(
									_formatTime(timestamp!),
									style: TextStyle(
										fontSize: 10,
										color: isUser
												? AppColors.white.withAlpha(179)
												: AppColors.textSecondary,
									),
								),
							],
						],
					),
				),
			),
		);
	}

	String _formatTime(DateTime time) {
		final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
		final minute = time.minute.toString().padLeft(2, '0');
		final period = time.hour >= 12 ? 'PM' : 'AM';
		return '$hour:$minute $period';
	}
}
