import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../auth/presentation/providers/enhanced_auth_provider.dart';
import '../providers/chat_provider.dart';
import '../../data/models/chat_message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_field.dart';

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
      // CRITICAL: Check if widget is still mounted before accessing context
      if (!mounted) return;
      
      final chatProvider = context.read<ChatProvider>();
      final authProvider = context.read<EnhancedAuthProvider>();
      final currentUser = authProvider.currentUser;
      
      if (currentUser != null) {
        // Initialize provider with user
        chatProvider.setUser(currentUser);
        
        if (widget.conversationId != null) {
          // Load existing conversation ONLY if it's different from current
          // This preserves the local state (greeting, chart data) when navigating from TuViResultPage
          if (chatProvider.currentConversationId != widget.conversationId) {
            chatProvider.selectConversation(widget.conversationId!);
          }
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
        
        // Update credits in AuthProvider to keep UI in sync (optimistic update)
        // We use the 'credits' variable captured before sending
        if (currentUser?.credits != null) {
           final newCredits = (currentUser!.credits!) - 1;
           authProvider.updateUserCredits(newCredits);
        }
        
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
      backgroundColor: AppColors.backgroundWarm,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.warmGradient,
        ),
        child: Stack(
          children: [
            // Decorative background elements
            _buildBackgroundDecorations(),
            
            // Main chat content
            Column(
              children: [
                Expanded(
                  child: _buildMessagesList(),
                ),
                _buildInputArea(),
              ],
            ),
            
            // Scroll to bottom button hidden - was overlapping send button
            // if (_showScrollToBottom)
            //   Positioned(
            //     right: 20,
            //     bottom: 120,
            //     child: _buildScrollToBottomFab(),
            //   ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Top right decorative circle
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
            ),
            // Bottom left decorative circle
            Positioned(
              bottom: 100,
              left: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      leading: const Padding(
        padding: EdgeInsets.all(8.0),
        child: StandardBackButton(),
      ),
      title: Row(
        children: [
          // AI Avatar with pastel background
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.iconBgYellow,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowYellow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '🌟',
                style: TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 14),
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: chatProvider.isAiTyping 
                                ? AppColors.warning 
                                : AppColors.success,
                            boxShadow: [
                              BoxShadow(
                                color: (chatProvider.isAiTyping 
                                    ? AppColors.warning 
                                    : AppColors.success).withValues(alpha: 0.4),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chatProvider.isAiTyping
                              ? 'Đang suy nghĩ...'
                              : 'Sẵn sàng giải đáp',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: chatProvider.isAiTyping 
                                ? AppColors.warning 
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
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
            return Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: PopupMenuButton<String>(
                onSelected: (value) => _handleMenuAction(value, chatProvider),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: AppColors.surface,
                elevation: 8,
                shadowColor: AppColors.shadowMedium,
                itemBuilder: (context) => [
                  _buildPopupMenuItem(
                    value: 'new_chat',
                    icon: Icons.add_comment_rounded,
                    iconColor: AppColors.secondary,
                    iconBgColor: AppColors.iconBgTeal,
                    text: 'Cuộc trò chuyện mới',
                  ),
                  _buildPopupMenuItem(
                    value: 'history',
                    icon: Icons.history_rounded,
                    iconColor: AppColors.info,
                    iconBgColor: AppColors.iconBgBlue,
                    text: 'Lịch sử trò chuyện',
                  ),
                  if (chatProvider.hasActiveConversation) ...[
                    const PopupMenuDivider(),
                    _buildPopupMenuItem(
                      value: 'clear_chat',
                      icon: Icons.clear_all_rounded,
                      iconColor: AppColors.warning,
                      iconBgColor: AppColors.warningLight,
                      text: 'Xóa nội dung chat',
                    ),
                    _buildPopupMenuItem(
                      value: 'delete_chat',
                      icon: Icons.delete_outline_rounded,
                      iconColor: AppColors.error,
                      iconBgColor: AppColors.errorLight,
                      text: 'Xóa cuộc trò chuyện',
                      textColor: AppColors.error,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0),
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.primary.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String text,
    Color? textColor,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: textColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgYellow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Đang tải...',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        if (chatProvider.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.defaultPadding,
            horizontal: 4,
          ),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decorative avatar container
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.iconBgYellow,
                    AppColors.primaryLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowYellow,
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '☯️',
                  style: TextStyle(fontSize: 56),
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            // Welcome card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.borderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Chào mừng đến với',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Trợ lý Tử Vi AI',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🌟 Giải đáp mọi thắc mắc về vận mệnh',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildSuggestedQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final suggestions = [
      {'icon': '🌟', 'text': 'Giải thích lá số tử vi của tôi'},
      {'icon': '💫', 'text': 'Cung Mệnh của tôi như thế nào?'},
      {'icon': '✨', 'text': 'Vận mệnh năm nay ra sao?'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Bắt đầu với câu hỏi:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ...suggestions.map((suggestion) {
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  _messageController.text = suggestion['text']!;
                  _onSendMessage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.borderYellow.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.iconBgYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            suggestion['icon']!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          suggestion['text']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  int _getItemCount(ChatProvider chatProvider) {
    int count = 0;

    // Add initial AI greeting if no messages
    if (chatProvider.messages.isEmpty) {
      count += 1; // AI greeting only (quick suggestions removed)
      return count;
    }

    // Count messages
    for (int i = 0; i < chatProvider.messages.length; i++) {
      count += 1; // Message
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

      // Quick suggestions removed - users can type their own questions
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
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowYellow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.small(
              onPressed: () => _scrollToBottom(),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.keyboard_arrow_down_rounded),
            ),
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
      case 'history':
        _showHistoryDialog(chatProvider);
        break;
      case 'clear_chat':
        _showClearChatDialog(chatProvider);
        break;
      case 'delete_chat':
        _showDeleteChatDialog(chatProvider);
        break;
    }
  }

  void _showHistoryDialog(ChatProvider chatProvider) {
    // Fetch history when opening dialog
    chatProvider.fetchUserConversations();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Consumer<ChatProvider>(
        builder: (context, provider, child) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.65,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.iconBgBlue,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          color: AppColors.info,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Lịch sử trò chuyện',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.divider),
                // Content
                Expanded(
                  child: provider.conversationIds.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 36,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có cuộc trò chuyện nào',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.conversationIds.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final id = provider.conversationIds[index];
                            final isSelected = id == provider.currentConversationId;
                            
                            return Material(
                              color: isSelected 
                                  ? AppColors.primarySoft 
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.pop(context);
                                  if (!isSelected) {
                                    provider.selectConversation(id);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected 
                                          ? AppColors.primary.withValues(alpha: 0.5)
                                          : AppColors.borderLight,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isSelected 
                                              ? AppColors.iconBgYellow 
                                              : AppColors.surfaceVariant,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          Icons.chat_bubble_outline_rounded,
                                          color: isSelected 
                                              ? AppColors.primary 
                                              : AppColors.textTertiary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Cuộc trò chuyện #$id',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              isSelected ? '● Đang xem' : 'Nhấn để xem lại',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isSelected 
                                                    ? AppColors.primary 
                                                    : AppColors.textTertiary,
                                                fontWeight: isSelected 
                                                    ? FontWeight.w600 
                                                    : FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: const Text(
                                            'Hiện tại',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textOnPrimary,
                                            ),
                                          ),
                                        )
                                      else
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          size: 16,
                                          color: AppColors.textTertiary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMessageOptions(dynamic message) {
    // TODO: Implement message options (copy, delete, etc.)
  }

  void _showClearChatDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.clear_all_rounded,
                color: AppColors.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Xóa cuộc trò chuyện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa cuộc trò chuyện này? Hành động này sẽ bắt đầu một cuộc trò chuyện mới.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              chatProvider.clearConversation();
              _messageController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog(ChatProvider chatProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Xóa cuộc trò chuyện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Lưu ý: API backend không hỗ trợ xóa cuộc trò chuyện. Việc xóa sẽ bắt đầu một cuộc trò chuyện mới thay thế.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              chatProvider.clearConversation();
              _messageController.clear();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Xóa',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCreditsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: AppColors.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        actionsPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppColors.warning,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Hết tín dụng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Tài khoản đã hết tín dụng để sử dụng AI Chatbot. Vui lòng nạp thêm tín dụng để tiếp tục.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.pushNamed('payment-packages');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, size: 18),
                SizedBox(width: 8),
                Text(
                  'Nạp ngay',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}
