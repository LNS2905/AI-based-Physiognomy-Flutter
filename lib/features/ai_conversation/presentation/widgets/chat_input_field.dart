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
        color: isDisabled 
            ? const Color(0xFFF5F5F5) 
            : const Color(0xFFFAFAFA),
        border: const Border(
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
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFD4AF37).withValues(alpha: 0.6),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'AI đang xử lý...',
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF666666).withValues(alpha: 0.7),
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
            ? const Color(0xFFF5F5F5) 
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDisabled 
              ? const Color(0xFFE0E0E0) 
              : const Color(0xFFDDDDDD),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        enabled: widget.enabled && !widget.isLoading,
        maxLines: null,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: isDisabled 
              ? const Color(0xFF999999) 
              : const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          hintText: isDisabled
              ? 'Đang chờ AI trả lời...'
              : (widget.hintText.isEmpty ? 'Hỏi về lá số tử vi của bạn...' : widget.hintText),
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDisabled 
                ? const Color(0xFFBBBBBB) 
                : const Color(0xFF999999),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
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
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: canSend
            ? const LinearGradient(
                colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: canSend ? null : const Color(0xFFE0E0E0),
        shape: BoxShape.circle,
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: canSend ? _onSendPressed : null,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        const Color(0xFF999999).withValues(alpha: 0.6),
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    size: 20,
                    color: canSend
                        ? Colors.white
                        : const Color(0xFF999999).withValues(alpha: 0.5),
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
          '💫 Gợi ý câu hỏi về Tử Vi:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
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
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnabled 
              ? const Color(0xFFD4AF37).withValues(alpha: 0.3) 
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
        color: isEnabled 
            ? const Color(0xFFF4E4BC).withValues(alpha: 0.2) 
            : const Color(0xFFF5F5F5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isEnabled
              ? () {
                  widget.controller.text = text;
                  widget.onChanged?.call(text);
                  widget.onSend?.call();
                }
              : null,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isEnabled 
                      ? const Color(0xFF333333) 
                      : const Color(0xFF999999),
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
