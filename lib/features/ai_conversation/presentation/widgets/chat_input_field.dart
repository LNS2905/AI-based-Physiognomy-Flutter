import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

/// Chat input field widget for typing and sending messages
class ChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool enabled;
  final bool isLoading;
  final VoidCallback? onSend;
  final ValueChanged<String>? onChanged;

  const ChatInputField({
    super.key,
    required this.controller,
    this.hintText = 'Nhập tin nhắn...',
    this.enabled = true,
    this.isLoading = false,
    this.onSend,
    this.onChanged,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
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
    final isDisabled = !widget.enabled || widget.isLoading;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main input row
            Row(
              children: [
                Expanded(
                  child: _buildTextField(),
                ),
                const SizedBox(width: 12),
                _buildSendButton(),
              ],
            ),
            if (!widget.isLoading) ...[
              const SizedBox(height: 16),
              // Suggested questions (only show when not loading)
              _buildSuggestedQuestions(),
            ] else ...[
              const SizedBox(height: 12),
              _buildLoadingIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'AI đang xử lý...',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    final isDisabled = !widget.enabled || widget.isLoading;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      constraints: const BoxConstraints(
        minHeight: 48,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: isDisabled 
            ? AppColors.surfaceVariant 
            : AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDisabled 
              ? AppColors.borderLight 
              : AppColors.border,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled && !widget.isLoading,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: isDisabled 
              ? AppColors.textTertiary 
              : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: isDisabled
              ? 'Đang chờ AI trả lời...'
              : (widget.hintText.isEmpty ? 'Hỏi về lá số tử vi của bạn...' : widget.hintText),
          hintStyle: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textHint,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
        onSubmitted: (_) {
          if (_hasText && !isDisabled) {
            _onSendPressed();
          }
        },
      ),
    );
  }

  Widget _buildSendButton() {
    final canSend = _hasText && widget.enabled && !widget.isLoading;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        // Cracker Book style: solid primary color when active
        color: canSend ? AppColors.primary : AppColors.surfaceVariant,
        shape: BoxShape.circle,
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: AppColors.shadowYellow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: canSend ? _onSendPressed : null,
          splashColor: AppColors.ripple,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.textTertiary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: 22,
                    // Cracker Book: dark icon on yellow background
                    color: canSend
                        ? AppColors.textOnPrimary
                        : AppColors.textHint,
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.iconBgYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '💫',
                style: TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Gợi ý câu hỏi về Tử Vi:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildSuggestionChip('Cung Tài Bạch như thế nào?'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSuggestionChip('Giải thích Cung Phu Thê'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String text) {
    final isEnabled = widget.enabled && !widget.isLoading;
    
    return Container(
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isEnabled 
              ? AppColors.borderYellow
              : AppColors.borderLight,
          width: 1.5,
        ),
        color: isEnabled 
            ? AppColors.surfaceYellow.withValues(alpha: 0.5) 
            : AppColors.surfaceVariant,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.ripple,
          onTap: isEnabled
              ? () {
                  widget.controller.text = text;
                  widget.onChanged?.call(text);
                  widget.onSend?.call();
                }
              : null,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isEnabled 
                      ? AppColors.textPrimary 
                      : AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
