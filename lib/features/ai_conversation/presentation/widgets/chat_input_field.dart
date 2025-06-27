import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_constants.dart';

/// Chat input field widget for typing and sending messages
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onSend;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onAttachmentTap;
  final bool showAttachmentButton;

  const ChatInputField({
    super.key,
    required this.controller,
    this.hintText = 'Type a message...',
    this.enabled = true,
    this.isLoading = false,
    this.onSend,
    this.onChanged,
    this.onAttachmentTap,
    this.showAttachmentButton = false,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with TickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late Animation<double> _sendButtonAnimation;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _sendButtonController = AnimationController(
      duration: AppConstants.shortAnimationDuration,
      vsync: this,
    );
    _sendButtonAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sendButtonController,
      curve: Curves.easeInOut,
    ));

    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
    if (_hasText) {
      _sendButtonController.forward();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _sendButtonController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      if (hasText) {
        _sendButtonController.forward();
      } else {
        _sendButtonController.reverse();
      }
    }
    widget.onChanged?.call(widget.controller.text);
  }

  void _onSendPressed() {
    if (_hasText && !widget.isLoading && widget.enabled) {
      HapticFeedback.lightImpact();
      widget.onSend?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAFA),
        border: Border(
          top: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main input row
            Row(
              children: [
                _buildAttachmentButton(),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTextField(),
                ),
                const SizedBox(width: 8),
                _buildVoiceButton(),
                const SizedBox(width: 8),
                _buildSendButton(),
              ],
            ),
            const SizedBox(height: 16),
            // Suggested questions
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 48,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled && !widget.isLoading,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText.isEmpty ? 'Ask me about your analysis...' : widget.hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF999999),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) {
          if (_hasText) {
            _onSendPressed();
          }
        },
      ),
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _sendButtonAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _sendButtonAnimation.value,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _hasText && widget.enabled && !widget.isLoading
                  ? const Color(0xFF999999)
                  : const Color(0xFFDDDDDD),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: _hasText && widget.enabled && !widget.isLoading
                    ? _onSendPressed
                    : null,
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          '→',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _hasText && widget.enabled
                                ? Colors.white
                                : const Color(0xFF999999),
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttachmentButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFCCCCCC),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.enabled && !widget.isLoading
              ? widget.onAttachmentTap
              : null,
          child: const Center(
            child: Text(
              '📎',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceButton() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFCCCCCC),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: widget.enabled && !widget.isLoading
              ? () {
                  // TODO: Implement voice recording
                }
              : null,
          child: const Center(
            child: Text(
              '🎤',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggested questions:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSuggestionChip('What about my nose shape?'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSuggestionChip('Explain facial harmony'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.enabled && !widget.isLoading
              ? () {
                  widget.controller.text = text;
                  widget.onChanged?.call(text);
                  widget.onSend?.call();
                }
              : null,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
