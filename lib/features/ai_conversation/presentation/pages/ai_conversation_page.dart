import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

/// AI Conversation page for chatting with AI assistant
class AIConversationPage extends StatefulWidget {
  final int? conversationId;

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
      final authProvider = context.read<EnhancedAuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        // Initialize provider with user
        chatProvider.setUser(currentUser);
        
        if (widget.conversationId != null) {
          // Load existing conversation
          chatProvider.selectConversation(widget.conversationId!);
        } else {
          // Clear any previous conversation (will create new on first message)
          chatProvider.clearConversation();
        }
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

    // TODO: TEMPORARILY DISABLED FOR TESTING - RE-ENABLE LATER
    // Check if user has enough credits
    // final authProvider = context.read<EnhancedAuthProvider>();
    // final currentUser = authProvider.currentUser;
    // final credits = currentUser?.credits ?? 0;

    // if (credits < 1) {
    //   _showInsufficientCreditsDialog();
    //   return;
    // }

    final chatProvider = context.read<ChatProvider>();
    
    // Clear the input field immediately
    _messageController.clear();
    
    // Send the message
    chatProvider.sendMessage(message).then((success) {
      if (success) {
        // Scroll to bottom to show new messages
        _scrollToBottom();
        
        // Refresh user data to get updated credits (will happen automatically through API)
        // Credits are updated by backend when sending messages
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
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: AppColors.shadow,
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: StandardBackButton(),
      ),
      title: Row(
        children: [
          // AI Avatar with gold theme
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '星',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                      'Trợ lý Tử Vi AI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      chatProvider.isAiTyping
                          ? 'Đang suy nghĩ...'
                          : 'Sẵn sàng giải đáp',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: chatProvider.isAiTyping 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
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
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.2),
                    AppColors.primaryLight.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '☯️',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chào mừng đến với Trợ lý Tử Vi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tôi sẽ giúp bạn giải đáp các thắc mắc về lá số tử vi và vận mệnh của bạn',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      '🌟 Giải thích lá số tử vi của tôi',
      '💫 Cung Mệnh của tôi như thế nào?',
      '✨ Vận mệnh năm nay ra sao?',
    ];

    return Column(
      children: suggestions.map((suggestion) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: () {
              _messageController.text = suggestion;
              _onSendMessage();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              suggestion,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
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

      // Only show quick suggestions after first AI message if user hasn't sent any message
      if (i == 0 && 
          chatProvider.messages.length == 1 && 
          chatProvider.messages[i].sender == MessageSender.ai) {
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

      // Only show quick suggestions after first AI message AND if user hasn't sent any message yet
      // (messages.length == 1 means only the AI welcome message exists)
      if (i == 0 && 
          chatProvider.messages.length == 1 && 
          chatProvider.messages[i].sender == MessageSender.ai) {
        if (currentIndex == index) {
          return QuickSuggestionButtons(
            suggestions: ['Phân tích 14 chính tinh', 'Giải thích Đại Hạn'],
            onSuggestionTap: (suggestion) {
              _messageController.text = suggestion;
              _onSendMessage();
            },
          );
        }
        currentIndex++;
      }
    }

    // Typing indicator
    if (chatProvider.isAiTyping && currentIndex == index) {
      return TypingIndicator(
        isVisible: chatProvider.isAiTyping,
        customText: 'Đang suy nghĩ về lá số của bạn',
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInitialAIGreeting() {
    final greetingMessage = ChatMessageModel.ai(
      id: 'greeting',
      content: "Xin chào! 🌟 Tôi là trợ lý Tử Vi AI của bạn. Tôi sẽ giúp bạn hiểu rõ về lá số tử vi và vận mệnh của mình.",
    );

    return MessageBubble(
      message: greetingMessage,
      showTimestamp: true,
    );
  }

  Widget _buildInitialQuickSuggestions() {
    return QuickSuggestionButtons(
      suggestions: ['Giải thích Cung Mệnh', 'Phân tích 12 cung'],
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
        chatProvider.clearConversation();
        _messageController.clear();
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text(
          'Are you sure you want to clear this conversation? This will start a new chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              chatProvider.clearConversation();
              _messageController.clear();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text(
          'Note: The backend API does not support deleting conversations. Clearing will start a new chat instead.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              chatProvider.clearConversation();
              _messageController.clear();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }


}
