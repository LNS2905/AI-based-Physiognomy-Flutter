import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/models/chat_message_model.dart';

/// Message bubble widget for displaying chat messages
class MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.showAvatar = true,
    this.showTimestamp = false,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final isSystem = message.sender == MessageSender.system;

    if (isSystem) {
      return _buildSystemMessage(context);
    }

    return Container(
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
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: AppColors.border,
                  width: 1,
                ),
          boxShadow: isUser
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
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
        return Text(
          message.content,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: isUser ? Colors.white : const Color(0xFF333333),
            height: 1.4,
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
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isUser ? Colors.white : AppColors.textPrimary,
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
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: isUser
            ? null
            : LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isUser ? AppColors.primaryLight : null,
        shape: BoxShape.circle,
        border: Border.all(
          color: isUser ? AppColors.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          isUser ? '👤' : '星',
          style: TextStyle(
            fontSize: isUser ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isUser ? AppColors.primary : Colors.white,
          ),
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
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF999999),
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
                  ? Colors.white.withValues(alpha: 0.7)
                  : AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'Sending...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: message.sender == MessageSender.user
                ? Colors.white.withValues(alpha: 0.7)
                : AppColors.textSecondary,
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
