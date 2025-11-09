import 'dart:async';
import 'dart:math';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../auth/data/models/auth_models.dart';
import '../../data/models/chat_message_model.dart';
import '../../data/models/chat_request_model.dart';
import '../../data/repositories/chat_repository.dart';

/// Provider for managing AI chat state and operations
class ChatProvider extends BaseProvider {
  final ChatRepository _repository;

  ChatProvider({ChatRepository? repository})
      : _repository = repository ?? ChatRepository();

  // Current conversation state
  int? _currentConversationId;
  List<ChatMessageModel> _messages = [];
  bool _isTyping = false;
  bool _isAiTyping = false;
  String _currentMessage = '';
  Timer? _typingTimer;
  User? _currentUser;

  // Getters
  int? get currentConversationId => _currentConversationId;
  List<ChatMessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get isAiTyping => _isAiTyping;
  String get currentMessage => _currentMessage;
  bool get hasActiveConversation => _currentConversationId != null;
  bool get canSendMessage => _currentMessage.trim().isNotEmpty && !_isAiTyping && hasActiveConversation;

  /// Initialize chat provider with user
  Future<void> initialize(User user) async {
    AppLogger.info('Initializing chat provider for user: ${user.id}');
    _currentUser = user;
    notifyListeners();
  }

  /// Set current user
  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  /// Create a new conversation
  Future<bool> createNewConversation({int? chartId}) async {
    if (_currentUser == null) {
      AppLogger.error('Cannot create conversation: No user set');
      return false;
    }

    // User.id is already an int, no need to parse
    final userId = _currentUser!.id;
    
    final result = await executeApiOperation(
      () => _repository.startConversation(userId, chartId: chartId),
      operationName: 'createNewConversation',
    );

    if (result != null) {
      _currentConversationId = result;
      _messages = [];
      AppLogger.info('Created new conversation: $result');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Select an existing conversation and load its history
  Future<void> selectConversation(int conversationId) async {
    _currentConversationId = conversationId;
    _messages = [];
    notifyListeners();

    // Load conversation history from API
    final result = await executeApiOperation(
      () => _repository.getConversationHistory(conversationId),
      operationName: 'selectConversation',
    );

    if (result != null) {
      _messages = result;
      AppLogger.info('Loaded conversation with ${_messages.length} messages');
      notifyListeners();
    }
  }

  /// Send a message to the AI
  Future<bool> sendMessage(String message) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) return false;

    // Create new conversation if none exists
    if (_currentConversationId == null) {
      final created = await createNewConversation();
      if (!created || _currentConversationId == null) {
        AppLogger.error('Failed to create conversation');
        return false;
      }
    }

    // Create user message
    final userMessage = ChatMessageModel.user(
      id: _generateId(),
      content: trimmedMessage,
    );

    // Add user message to list
    _messages.add(userMessage);
    _currentMessage = '';
    _setAiTyping(true);
    notifyListeners();

    // Send message to API
    final request = ChatRequestModel.text(
      message: trimmedMessage,
      conversationId: _currentConversationId!,
      context: _buildContext(),
    );

    final result = await executeApiOperation(
      () => _repository.sendMessage(request),
      operationName: 'sendMessage',
      showLoading: false,
    );

    _setAiTyping(false);

    if (result != null) {
      // Add AI response to list
      _messages.add(result);
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

  /// Clear current conversation (start fresh)
  void clearConversation() {
    _currentConversationId = null;
    _messages = [];
    _currentMessage = '';
    notifyListeners();
    AppLogger.info('Cleared conversation');
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

  /// Build context for API requests
  Map<String, dynamic> _buildContext() {
    return {
      'platform': 'mobile',
      'app_version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'message_count': _messages.length,
      if (_currentUser != null) 'user_id': _currentUser!.id,
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
