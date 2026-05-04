import 'package:flutter/material.dart' hide Icons;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/ai_assistant_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAssistant();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeAssistant() async {
    if (_isInitialized) return;

    final authState = ref.read(authStateProvider);
    final userId = authState.value?.uid;

    if (userId == null || !mounted) return;

    try {
      final assistantService = ref.read(assistantServiceProvider);
      await assistantService.initializeForUser(userId);
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize assistant: $error')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty || !_isInitialized) return;

    _controller.clear();
    await ref.read(currentConversationProvider.notifier).sendMessageStreamed(message);
    _scrollToBottom();
  }

  Future<void> _handleSuggestion(String message) async {
    if (!_isInitialized) return;
    await ref.read(currentConversationProvider.notifier).sendMessageStreamed(message);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(currentConversationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AssistantHeader(onMenuTap: () {}),
                        const SizedBox(height: 14),
                        if (conversationState.messages.isEmpty)
                          _InitialPrompt(onSuggestionTap: _handleSuggestion)
                        else
                          _ConversationHistory(messages: conversationState.messages),
                        if (conversationState.isLoading)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: _TypingIndicator(),
                          ),
                        if (conversationState.error != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _ErrorMessage(
                              error: conversationState.error!,
                              onDismiss: () {
                                ref.read(currentConversationProvider.notifier).clearError();
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        _CircleActionButton(
                          icon: AppIcons.add_rounded,
                          onPressed: () {
                            ref.read(currentConversationProvider.notifier).clearConversation();
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.border),
                            ),
                            alignment: Alignment.centerLeft,
                            child: TextField(
                              controller: _controller,
                              enabled: _isInitialized && !conversationState.isLoading,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                hintText: 'Message DailyDose AI...',
                                hintStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: _isInitialized && !conversationState.isLoading && _controller.text.isNotEmpty
                              ? _sendMessage
                              : null,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (_isInitialized && !conversationState.isLoading && _controller.text.isNotEmpty)
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withAlpha(102),
                            ),
                            child: const Icon(
                              AppIcons.arrow_upward_rounded,
                              size: 18,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: AppColors.textSecondary),
        onPressed: onPressed,
        splashRadius: 15,
      ),
    );
  }
}

class _InitialPrompt extends StatelessWidget {
  const _InitialPrompt({required this.onSuggestionTap});

  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF0FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              AppIcons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'How can I help you\ntoday?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'I can analyze your health logs, prepare\nyou for upcoming appointments, or\nanswer questions about your medications.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _SectionLabel('SUGGESTED'),
          const SizedBox(height: 10),
          _SuggestionTile(
            icon: AppIcons.monitor_heart_outlined,
            iconColor: Color(0xFF10B981),
            title: 'Analyze my recent health trends',
            onTap: () => onSuggestionTap(
              'Can you analyze my recent health logs and identify any concerning trends or patterns?',
            ),
          ),
          const SizedBox(height: 8),
          _SuggestionTile(
            icon: AppIcons.event_available_outlined,
            iconColor: AppColors.primary,
            title: 'Prepare for my next appointment',
            onTap: () => onSuggestionTap(
              'Please help me prepare for my upcoming doctor appointment. What questions should I ask and what information should I bring?',
            ),
          ),
          const SizedBox(height: 8),
          _SuggestionTile(
            icon: AppIcons.medication_outlined,
            iconColor: Color(0xFFF59E0B),
            title: 'Questions about my medications',
            onTap: () => onSuggestionTap(
              'I have questions about my current medications. Can you explain how they work and what side effects I should watch for?',
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationHistory extends StatelessWidget {
  const _ConversationHistory({required this.messages});

  final List<ChatMessage> messages;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: messages
          .map(
            (message) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ChatBubble(message: message),
            ),
          )
          .toList(),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: message.isUser ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: message.isUser ? null : Border.all(color: AppColors.border),
          ),
          child: Text(
            message.text,
            style: TextStyle(
              fontSize: 13,
              color: message.isUser ? AppColors.white : AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
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
      alignment: Alignment.centerLeft,
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
            _Dot(animation: _animate(0.0, 0.33)),
            const SizedBox(width: 4),
            _Dot(animation: _animate(0.33, 0.66)),
            const SizedBox(width: 4),
            _Dot(animation: _animate(0.66, 1.0)),
          ],
        ),
      ),
    );
  }

  Animation<double> _animate(double begin, double end) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: Curves.easeInOut),
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
        return Transform.translate(
          offset: Offset(0, -animation.value * 4),
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error, required this.onDismiss});

  final String error;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF5350)),
      ),
      child: Row(
        children: [
          const Icon(
            AppIcons.warning_amber,
            color: Color(0xFFEF5350),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(fontSize: 12, color: Color(0xFFEF5350)),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Icon(
              AppIcons.close,
              color: Color(0xFFEF5350),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantHeader extends StatelessWidget {
  const _AssistantHeader({required this.onMenuTap});

  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEAF0FF),
            border: Border.all(color: const Color(0xFFD6E4FF)),
          ),
          child: const Icon(
            AppIcons.auto_awesome_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DailyDose AI',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Always here for you',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(AppIcons.more_vert_rounded),
          splashRadius: 20,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: iconColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              AppIcons.chevron_right_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
