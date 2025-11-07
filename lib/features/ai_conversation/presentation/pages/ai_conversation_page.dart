import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/quick_suggestion_buttons.dart';
import '../widgets/analysis_report_card.dart';
import '../widgets/quick_action_buttons.dart';

/// AI Conversation page for chatting with AI assistant
class AIConversationPage extends StatefulWidget {
  final String? conversationId;

  const AIConversationPage({
    super.key,
    this.conversationId,
  });

  @override
  State<AIConversationPage> createState() => _AIConversationPageState();
}

class _AIConversationPageState extends State<AIConversationPage>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _fabController = AnimationController(
      duration: AppConstants.shortAnimationDuration,
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    ));

    _scrollController.addListener(_onScroll);
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      
      if (widget.conversationId != null) {
        chatProvider.selectConversation(widget.conversationId!);
      } else {
        // Start with a new conversation
        chatProvider.createNewConversation();
      }
      
      // Scroll to bottom after messages load
      _scrollToBottom();
    });
  }

  void _onScroll() {
    final showFab = _scrollController.hasClients &&
        _scrollController.offset > 100;
    
    if (showFab != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showFab;
      });
      
      if (showFab) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      if (animated) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: AppConstants.mediumAnimationDuration,
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    }
  }

  void _onSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Check if user has enough credits
    final authProvider = context.read<EnhancedAuthProvider>();
    final currentUser = authProvider.currentUser;
    final credits = currentUser?.credits ?? 0;

    if (credits < 1) {
      _showInsufficientCreditsDialog();
      return;
    }

    final chatProvider = context.read<ChatProvider>();
    
    // Clear the input field immediately
    _messageController.clear();
    
    // Send the message
    chatProvider.sendMessage(message).then((success) {
      if (success) {
        // Scroll to bottom to show new messages
        _scrollToBottom();
        
        // Refresh user data to get updated credits
        authProvider.getCurrentUser();
      } else {
        // Show error if message failed to send
        if (mounted && chatProvider.hasError) {
          ErrorHandler.handleError(
            context,
            chatProvider.failure!,
            showSnackBar: true,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // Main chat content
          Column(
            children: [
              Expanded(
                child: _buildMessagesList(),
              ),
              _buildInputArea(),
              const SizedBox(height: 100), // Space for fixed navigation
            ],
          ),
          
          // Floating action button (if needed)
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 120, // Above the fixed navigation
              child: _buildScrollToBottomFab(),
            ),
          
          // Fixed Bottom Navigation
          FixedBottomNavigation(currentRoute: '/ai-conversation'),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFAFAFA),
      elevation: 0,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: StandardBackButton(),
      ),
      title: Row(
        children: [
          // AI Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF999999),
                width: 2,
              ),
            ),
            child: const Center(
              child: Text(
                'AI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title and Status
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Trợ lý AI Trò chuyện',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333333),
                      ),
                    ),
                    Text(
                      chatProvider.isAiTyping
                          ? 'AI đang nhập...'
                          : 'Trực tuyến • Sẵn sàng giúp đỡ',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            return PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, chatProvider),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new_chat',
                  child: Row(
                    children: [
                      Icon(Icons.add_comment_outlined),
                      SizedBox(width: 8),
                      Text('Cuộc trò chuyện mới'),
                    ],
                  ),
                ),
                if (chatProvider.hasActiveConversation) ...[
                  const PopupMenuItem(
                    value: 'clear_chat',
                    child: Row(
                      children: [
                        Icon(Icons.clear_all_outlined),
                        SizedBox(width: 8),
                        Text('Xóa cuộc trò chuyện'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete_chat',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: AppColors.error),
                        SizedBox(width: 8),
                        Text('Xóa cuộc trò chuyện', style: TextStyle(color: AppColors.error)),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.smallPadding),
          itemCount: _getItemCount(chatProvider),
          itemBuilder: (context, index) {
            return _buildChatItem(context, chatProvider, index);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bắt đầu cuộc trò chuyện',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hỏi tôi bất cứ điều gì! Tôi ở đây để giúp bạn trả lời câu hỏi và cung cấp thông tin chi tiết.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      'Bạn có thể giúp tôi điều gì?',
      'Hãy kể cho tôi về tướng học',
      'Phân tích khuôn mặt hoạt động như thế nào?',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            onPressed: () {
              _messageController.text = suggestion;
              _onSendMessage();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF666666),
              side: const BorderSide(color: Color(0xFFDDDDDD)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
            child: Text(suggestion),
          ),
        );
      }).toList(),
    );
  }

  int _getItemCount(ChatProvider chatProvider) {
    int count = 0;

    // Add initial AI greeting if no messages
    if (chatProvider.messages.isEmpty) {
      count += 1; // AI greeting
      count += 1; // Quick suggestions
      return count;
    }

    // Count messages and special items
    for (int i = 0; i < chatProvider.messages.length; i++) {
      count += 1; // Message

      // Add quick suggestions after first AI message
      if (i == 0 && chatProvider.messages[i].sender == MessageSender.ai) {
        count += 1;
      }

      // Add analysis report card after specific messages
      if (i == 1 && chatProvider.messages.length > 1) {
        count += 1;
      }

      // Add quick actions after analysis report
      if (i == 1 && chatProvider.messages.length > 2) {
        count += 1;
      }
    }

    // Add typing indicator if AI is typing
    if (chatProvider.isAiTyping) {
      count += 1;
    }

    return count;
  }

  Widget _buildChatItem(BuildContext context, ChatProvider chatProvider, int index) {
    if (chatProvider.messages.isEmpty) {
      if (index == 0) {
        return _buildInitialAIGreeting();
      } else if (index == 1) {
        return _buildInitialQuickSuggestions();
      }
    }


    int currentIndex = 0;

    for (int i = 0; i < chatProvider.messages.length; i++) {
      if (currentIndex == index) {
        return MessageBubble(
          message: chatProvider.messages[i],
          showTimestamp: true,
          onLongPress: () => _showMessageOptions(chatProvider.messages[i]),
        );
      }
      currentIndex++;

      // Add quick suggestions after first AI message
      if (i == 0 && chatProvider.messages[i].sender == MessageSender.ai) {
        if (currentIndex == index) {
          return QuickSuggestionButtons(
            suggestions: ['Giải thích kết quả của tôi', 'Hỏi về các tính năng'],
            onSuggestionTap: (suggestion) {
              _messageController.text = suggestion;
              _onSendMessage();
            },
          );
        }
        currentIndex++;
      }

      // Add analysis report card after specific messages
      if (i == 1 && chatProvider.messages.length > 1) {
        if (currentIndex == index) {
          return AnalysisReportCard(
            title: 'Báo cáo phân tích khuôn mặt của bạn',
            subtitle: 'Điểm tổng thể: 87% • 6 tính năng đã phân tích',
            description: 'Nhấn để xem phân tích chi tiết',
            onTap: () {
              // TODO: Navigate to detailed analysis
            },
          );
        }
        currentIndex++;
      }

      // Add quick actions after analysis report
      if (i == 1 && chatProvider.messages.length > 2) {
        if (currentIndex == index) {
          return QuickActionButtons(
            actions: [
              QuickAction(
                title: 'Chia sẻ phân tích',
                onTap: () {
                  // TODO: Implement share functionality
                },
              ),
              QuickAction(
                title: 'So sánh tính năng',
                onTap: () {
                  // TODO: Implement compare functionality
                },
              ),
            ],
          );
        }
        currentIndex++;
      }
    }

    // Typing indicator
    if (chatProvider.isAiTyping && currentIndex == index) {
      return TypingIndicator(
        isVisible: chatProvider.isAiTyping,
        customText: 'AI đang suy nghĩ',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInitialAIGreeting() {
    final greetingMessage = ChatMessageModel.ai(
      id: 'greeting',
      content: "Xin chào! Tôi là trợ lý tướng học AI của bạn. Tôi có thể giúp bạn hiểu kết quả phân tích khuôn mặt của mình.",
    );

    return MessageBubble(
      message: greetingMessage,
      showTimestamp: true,
    );
  }

  Widget _buildInitialQuickSuggestions() {
    return QuickSuggestionButtons(
      suggestions: ['Giải thích kết quả của tôi', 'Hỏi về các tính năng'],
      onSuggestionTap: (suggestion) {
        _messageController.text = suggestion;
        _onSendMessage();
      },
    );
  }

  Widget _buildInputArea() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return ChatInputField(
          controller: _messageController,
          enabled: !chatProvider.isLoading,
          isLoading: chatProvider.isAiTyping,
          onSend: _onSendMessage,
          onChanged: chatProvider.updateCurrentMessage,
          showAttachmentButton: true,
          onAttachmentTap: () {
            // TODO: Implement attachment functionality
          },
        );
      },
    );
  }

  Widget _buildScrollToBottomFab() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        if (_fabAnimation.value == 0.0) {
          return const SizedBox.shrink();
        }

        return Transform.scale(
          scale: _fabAnimation.value,
          child: FloatingActionButton.small(
            onPressed: () => _scrollToBottom(),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.keyboard_arrow_down),
          ),
        );
      },
    );
  }

  void _handleMenuAction(String action, ChatProvider chatProvider) {
    switch (action) {
      case 'new_chat':
        chatProvider.createNewConversation();
        break;
      case 'clear_chat':
        _showClearChatDialog(chatProvider);
        break;
      case 'delete_chat':
        _showDeleteChatDialog(chatProvider);
        break;
    }
  }

  void _showMessageOptions(dynamic message) {
    // TODO: Implement message options (copy, delete, etc.)
  }

  void _showClearChatDialog(ChatProvider chatProvider) {
    // TODO: Implement clear chat dialog
  }

  void _showDeleteChatDialog(ChatProvider chatProvider) {
    // TODO: Implement delete chat dialog
  }

  /// Show insufficient credits dialog
  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Insufficient Credits'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You need at least 1 credit to send a message to the AI chatbot.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Would you like to buy more credits?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/payment/packages');
            },
            child: const Text('Buy Credits'),
          ),
        ],
      ),
    );
  }
}
