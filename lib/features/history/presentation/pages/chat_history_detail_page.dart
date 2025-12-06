import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../ai_conversation/data/models/chat_message_model.dart';
import '../../../ai_conversation/presentation/widgets/message_bubble.dart';
import '../../data/models/chat_history_model.dart';
import '../providers/history_provider.dart';

/// Detail page for chat conversation history item
class ChatHistoryDetailPage extends StatefulWidget {
  final String historyId;

  const ChatHistoryDetailPage({
    super.key,
    required this.historyId,
  });

  @override
  State<ChatHistoryDetailPage> createState() => _ChatHistoryDetailPageState();
}

class _ChatHistoryDetailPageState extends State<ChatHistoryDetailPage> {
  ChatHistoryModel? _historyItem;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadHistoryItem();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadHistoryItem() {
    final provider = context.read<HistoryProvider>();
    final item = provider.getHistoryItemById(widget.historyId);
    
    if (item is ChatHistoryModel) {
      setState(() {
        _historyItem = item;
      });
    } else {
      AppLogger.error('History item not found or wrong type: ${widget.historyId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_historyItem == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.all(8.0),
            child: StandardBackButton(),
          ),
          title: const Text(
            'Chi tiết cuộc trò chuyện',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Text(
            'Không tìm thấy cuộc trò chuyện',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildConversationInfo(),
                  Expanded(
                    child: _buildMessagesList(),
                  ),
                  _buildActionBar(),
                ],
              ),
            ),
          ),
          FixedBottomNavigation(
            currentRoute: '/history',
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: StandardBackButton(),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _historyItem!.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_historyItem!.messageCount} tin nhắn • ${_historyItem!.formattedDate}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Favorite button
          Consumer<HistoryProvider>(
            builder: (context, provider, child) {
              return IconButton(
                onPressed: () => provider.toggleFavorite(_historyItem!.id),
                icon: Icon(
                  _historyItem!.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _historyItem!.isFavorite ? AppColors.accent : AppColors.textSecondary,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _historyItem!.isFavorite 
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConversationInfo() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Conversation icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('💬', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          
          // Conversation details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _historyItem!.conversation.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Thời lượng: ${_historyItem!.conversationDuration}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicators
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_historyItem!.unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_historyItem!.unreadCount}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 2),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _historyItem!.isActive ? AppColors.success : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = _historyItem!.conversation.messages;
    
    if (messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'Chưa có tin nhắn nào',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final showTimestamp = index == 0 || 
            _shouldShowTimestamp(messages[index - 1], message);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: MessageBubble(
            message: message,
            showTimestamp: showTimestamp,
            onLongPress: () => _showMessageOptions(message),
          ),
        );
      },
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Continue conversation button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _continueConversation,
              icon: const Icon(Icons.chat),
              label: const Text('Tiếp tục trò chuyện'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowTimestamp(ChatMessageModel previousMessage, ChatMessageModel currentMessage) {
    final timeDifference = currentMessage.timestamp.difference(previousMessage.timestamp);
    return timeDifference.inMinutes > 5; // Show timestamp if more than 5 minutes apart
  }

  void _showMessageOptions(ChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Sao chép tin nhắn'),
              onTap: () {
                Navigator.of(context).pop();
                _copyMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Thông tin tin nhắn'),
              onTap: () {
                Navigator.of(context).pop();
                _showMessageInfo(message);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage(ChatMessageModel message) {
    Clipboard.setData(ClipboardData(text: message.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép tin nhắn'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showMessageInfo(ChatMessageModel message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin tin nhắn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Người gửi: ${message.sender == MessageSender.user ? "Người dùng" : "AI"}'),
            Text('Thời gian: ${message.timestamp.toString()}'),
            Text('Loại: ${message.type == MessageType.text ? "Văn bản" : "Hình ảnh"}'),
            Text('Trạng thái: ${message.isDelivered ? "Đã gửi" : "Đang gửi"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _continueConversation() {
    // Navigate to AI conversation page with this conversation
    context.push('${AppConstants.aiConversationRoute}?id=${_historyItem!.conversation.id}');
  }
}
