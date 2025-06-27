import 'dart:async';
import 'dart:math';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/chat_request_model.dart';
import '../../data/repositories/chat_repository.dart';

/// Provider for managing AI chat state and operations
class ChatProvider extends BaseProvider {
  final ChatRepository _repository;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  // Current conversation state
  ConversationModel? _currentConversation;
  List<ConversationModel> _conversations = [];
  bool _isTyping = false;
  bool _isAiTyping = false;
  String _currentMessage = '';
  Timer? _typingTimer;

  // Getters
  ConversationModel? get currentConversation => _currentConversation;
  List<ConversationModel> get conversations => _conversations;
  List<ChatMessageModel> get messages => _currentConversation?.messages ?? [];
  bool get isTyping => _isTyping;
  bool get isAiTyping => _isAiTyping;
  String get currentMessage => _currentMessage;
  bool get hasActiveConversation => _currentConversation != null;
  bool get canSendMessage => _currentMessage.trim().isNotEmpty && !_isAiTyping;

  /// Initialize chat provider
  Future<void> initialize() async {
    AppLogger.info('Initializing chat provider');
    await loadConversations();
  }

  /// Load conversations from API
  Future<void> loadConversations() async {
    final result = await executeApiOperation(
      () => _repository.getConversations(),
      operationName: 'loadConversations',
    );

    if (result != null) {
      _conversations = result;
      AppLogger.info('Loaded ${_conversations.length} conversations');
      notifyListeners();
    }
  }

  /// Create a new conversation
  Future<bool> createNewConversation({String? title}) async {
    
    final result = await executeApiOperation(
      () => _repository.createConversation(
        title: title ?? 'New Conversation',
        metadata: {'created_from': 'mobile_app'},
      ),
      operationName: 'createNewConversation',
    );

    if (result != null) {
      _currentConversation = result;
      _conversations.insert(0, result);
      AppLogger.info('Created new conversation: ${result.id}');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Select an existing conversation
  Future<void> selectConversation(String conversationId) async {
    final existingConversation = _conversations
        .where((conv) => conv.id == conversationId)
        .firstOrNull;

    if (existingConversation != null) {
      _currentConversation = existingConversation;
      AppLogger.info('Selected conversation: $conversationId');
      notifyListeners();
      return;
    }

    // Load conversation from API if not in local list
    final result = await executeApiOperation(
      () => _repository.getConversation(conversationId),
      operationName: 'selectConversation',
    );

    if (result != null) {
      _currentConversation = result;
      // Add to conversations list if not already there
      if (!_conversations.any((conv) => conv.id == conversationId)) {
        _conversations.insert(0, result);
      }
      AppLogger.info('Loaded and selected conversation: $conversationId');
      notifyListeners();
    }
  }

  /// Send a message to the AI
  Future<bool> sendMessage(String message) async {
    if (!canSendMessage) return false;

    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return false;

    // Create user message
    final userMessage = ChatMessageModel.user(
      id: _generateId(),
      content: trimmedMessage,
    );

    // Add user message to conversation
    if (_currentConversation != null) {
      _currentConversation = _currentConversation!.addMessage(userMessage);
      _updateConversationInList(_currentConversation!);
    } else {
      // Create new conversation if none exists
      await createNewConversation();
      if (_currentConversation != null) {
        _currentConversation = _currentConversation!.addMessage(userMessage);
        _updateConversationInList(_currentConversation!);
      }
    }

    // Clear current message and show AI typing
    _currentMessage = '';
    _setAiTyping(true);
    notifyListeners();

    // Send message to API
    final request = ChatRequestModel.text(
      message: trimmedMessage,
      conversationId: _currentConversation?.id,
      context: _buildContext(),
    );

    final result = await executeApiOperation(
      () => _repository.sendMessage(request),
      operationName: 'sendMessage',
      showLoading: false,
    );

    _setAiTyping(false);

    if (result != null && _currentConversation != null) {
      // Add AI response to conversation
      _currentConversation = _currentConversation!.addMessage(result);
      _updateConversationInList(_currentConversation!);
      AppLogger.info('Received AI response: ${result.id}');
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Update current message being typed
  void updateCurrentMessage(String message) {
    _currentMessage = message;
    _setTyping(message.isNotEmpty);
    notifyListeners();
  }

  /// Clear current message
  void clearCurrentMessage() {
    _currentMessage = '';
    _setTyping(false);
    notifyListeners();
  }

  /// Delete a conversation
  Future<bool> deleteConversation(String conversationId) async {
    final result = await executeApiOperation(
      () => _repository.deleteConversation(conversationId),
      operationName: 'deleteConversation',
    );

    if (result == true) {
      _conversations.removeWhere((conv) => conv.id == conversationId);
      if (_currentConversation?.id == conversationId) {
        _currentConversation = null;
      }
      AppLogger.info('Deleted conversation: $conversationId');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update conversation title
  Future<bool> updateConversationTitle(String conversationId, String title) async {
    final result = await executeApiOperation(
      () => _repository.updateConversationTitle(conversationId, title),
      operationName: 'updateConversationTitle',
    );

    if (result != null) {
      _updateConversationInList(result);
      if (_currentConversation?.id == conversationId) {
        _currentConversation = result;
      }
      AppLogger.info('Updated conversation title: $conversationId');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Mark conversation as read
  void markConversationAsRead(String conversationId) {
    final conversationIndex = _conversations.indexWhere((conv) => conv.id == conversationId);
    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _conversations[conversationIndex].markAllAsRead();
      if (_currentConversation?.id == conversationId) {
        _currentConversation = _conversations[conversationIndex];
      }
      notifyListeners();
    }
  }

  /// Set typing indicator
  void _setTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      
      // Reset typing timer
      _typingTimer?.cancel();
      if (typing) {
        _typingTimer = Timer(const Duration(seconds: 3), () {
          _isTyping = false;
          notifyListeners();
        });
      }
    }
  }

  /// Set AI typing indicator
  void _setAiTyping(bool typing) {
    if (_isAiTyping != typing) {
      _isAiTyping = typing;
      notifyListeners();
    }
  }

  /// Update conversation in the list
  void _updateConversationInList(ConversationModel updatedConversation) {
    final index = _conversations.indexWhere((conv) => conv.id == updatedConversation.id);
    if (index != -1) {
      _conversations[index] = updatedConversation;
      // Move to top of list
      _conversations.removeAt(index);
      _conversations.insert(0, updatedConversation);
    } else {
      _conversations.insert(0, updatedConversation);
    }
  }

  /// Build context for API requests
  Map<String, dynamic> _buildContext() {
    return {
      'platform': 'mobile',
      'app_version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'message_count': _currentConversation?.messages.length ?? 0,
    };
  }

  /// Generate unique ID
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999999);
    return '${timestamp}_$random';
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
