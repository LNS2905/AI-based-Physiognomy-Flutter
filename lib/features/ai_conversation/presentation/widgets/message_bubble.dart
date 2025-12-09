import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/chat_message_model.dart';
import 'contextual_suggestions.dart';

/// Message bubble widget for displaying chat messages
class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onLongPress;
  final bool isLastAiMessage;
  final Function(String)? onSuggestionTap;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = false,
    this.onLongPress,
    this.isLastAiMessage = false,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;
    final isAi = message.sender == MessageSender.ai;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser && showAvatar) ...[
                _buildAvatar(context, isUser),
                const SizedBox(width: AppConstants.smallPadding),
              ],
              Flexible(
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    _buildMessageBubble(context, isUser),
                    if (showTimestamp) ...[
                      const SizedBox(height: 4),
                      _buildTimestamp(context, isUser),
                    ],
                  ],
                ),
              ),
              if (isUser && showAvatar) ...[
                const SizedBox(width: AppConstants.smallPadding),
                _buildAvatar(context, isUser),
              ],
            ],
          ),
        ),
        // Contextual suggestions for last AI message
        if (isAi && isLastAiMessage && onSuggestionTap != null)
          ContextualSuggestions(
            messageContent: message.content,
            onSuggestionTap: onSuggestionTap!,
            isLastMessage: isLastAiMessage,
          ),
      ],
    );
  }

  Widget _buildMessageBubble(BuildContext context, bool isUser) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: AppConstants.shortAnimationDuration,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          // Cracker Book style: solid colors, no gradients for bubbles
          color: isUser ? AppColors.chatUserBubble : AppColors.chatBotBubble,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          // Subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: isUser 
                  ? AppColors.shadowYellow 
                  : AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageContent(context, isUser),
            if (!message.isDelivered) ...[
              const SizedBox(height: 4),
              _buildDeliveryStatus(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUser) {
    switch (message.type) {
      case MessageType.text:
        return MarkdownBody(
          data: message.content,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              // Cracker Book: dark text on both bubbles for readability
              color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
              height: 1.5,
            ),
            strong: TextStyle(
              fontWeight: FontWeight.w600,
              color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
            ),
            em: TextStyle(
              fontStyle: FontStyle.italic,
              color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
            ),
            listBullet: TextStyle(
              color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
            ),
            code: TextStyle(
              backgroundColor: isUser 
                  ? AppColors.primaryDark.withValues(alpha: 0.2) 
                  : AppColors.border,
              color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
              fontSize: 13,
            ),
            blockquote: TextStyle(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.image_rounded,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUser ? AppColors.chatUserText : AppColors.chatBotText,
                ),
              ),
            ],
          ],
        );
      case MessageType.system:
        return Text(
          message.content,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  Widget _buildSystemMessage(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceYellow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        // Cracker Book style: pastel circle backgrounds
        color: isUser ? AppColors.iconBgPeach : AppColors.iconBgTeal,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: isUser
            ? const Icon(
                Icons.person_rounded,
                size: 20,
                color: AppColors.accent,
              )
            : const Text(
                '🌟',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }

  Widget _buildTimestamp(BuildContext context, bool isUser) {
    final timestampText = _formatTimestamp(message.timestamp);
    final displayText = isUser && message.isDelivered
        ? '$timestampText ✓✓'
        : timestampText;

    return Text(
      displayText,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textTertiary,
      ),
      textAlign: isUser ? TextAlign.right : TextAlign.left,
    );
  }

  Widget _buildDeliveryStatus(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              message.sender == MessageSender.user
                  ? AppColors.textSecondary
                  : AppColors.secondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Sending...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}
