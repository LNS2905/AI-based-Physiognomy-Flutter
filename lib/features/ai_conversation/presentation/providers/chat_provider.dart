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
  List<int> _conversationIds = [];
  bool _isTyping = false;
  bool _isAiTyping = false;
  String _currentMessage = '';
  Timer? _typingTimer;
  User? _currentUser;
  Map<String, dynamic>? _currentChartData; // Store chart data for Tu Vi analysis

  // Getters
  int? get currentConversationId => _currentConversationId;
  List<ChatMessageModel> get messages => _messages;
  List<int> get conversationIds => _conversationIds;
  bool get isTyping => _isTyping;
  bool get isAiTyping => _isAiTyping;
  String get currentMessage => _currentMessage;
  bool get hasActiveConversation => _currentConversationId != null;
  bool get canSendMessage => _currentMessage.trim().isNotEmpty && !_isAiTyping && hasActiveConversation;
  bool get hasTuViChart => _currentChartData != null;

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
  Future<bool> createNewConversation({
    int? chartId,
    Map<String, dynamic>? chartData,
  }) async {
    if (_currentUser == null) {
      AppLogger.error('Cannot create conversation: No user set');
      return false;
    }

    // Store chart data for Tu Vi analysis
    _currentChartData = chartData;

    // User.id is already an int, no need to parse
    final userId = _currentUser!.id;

    final result = await executeApiOperation(
      () => _repository.startConversation(userId.toString(), chartId: chartId),
      operationName: 'createNewConversation',
    );

    if (result != null) {
      _currentConversationId = result['conversation_id'] as int;
      _messages = [];

      // Add welcome message from backend (local only, not saved to history)
      final welcomeMessage = result['welcome_message'] as String?;
      if (welcomeMessage != null && welcomeMessage.isNotEmpty) {
        _addWelcomeMessageFromBackend(welcomeMessage);
      } else {
        // Fallback to local message if backend doesn't provide one
        _addWelcomeMessage(chartId);
      }

      AppLogger.info('Created new conversation: $_currentConversationId with Tu Vi chart: ${_currentChartData != null}');
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Add welcome message from backend
  void _addWelcomeMessageFromBackend(String message) {
    final now = DateTime.now();
    final welcomeMessage = ChatMessageModel.ai(
      id: 'welcome_${now.millisecondsSinceEpoch}',
      content: message,
      isDelivered: true,
    );
    _messages.insert(0, welcomeMessage);
  }

  /// Add welcome message (displayed locally, not saved to history)
  void _addWelcomeMessage(int? chartId) {
    final now = DateTime.now();
    final hasTuViData = _currentChartData != null;

    final welcomeText = chartId != null && hasTuViData
        ? '''Xin chào! Tôi là trợ lý AI tử vi của bạn. 🌟

✅ Tôi đã nhận được lá số tử vi đầy đủ của bạn!

⚡ Phân tích NHANH (8-15 giây) - Hãy đặt câu hỏi về:
• Tính cách và vận mệnh
• Sự nghiệp và tài lộc
• Tình duyên và hôn nhân
• Sức khỏe và gia đạo
• Hoặc bất kỳ khía cạnh nào khác trong lá số

Bạn muốn hỏi tôi điều gì?'''
        : '''Xin chào! Tôi là trợ lý AI tử vi của bạn. 🌟

Tôi có thể giúp bạn tìm hiểu về:
• Lá số tử vi
• Vận mệnh và tính cách
• Sự nghiệp và tình duyên
• Các câu hỏi về phong thủy

Bạn muốn hỏi tôi điều gì?''';

    final welcomeMessage = ChatMessageModel.ai(
      id: 'welcome_${now.millisecondsSinceEpoch}',
      content: welcomeText,
      isDelivered: true,
    );

    _messages.insert(0, welcomeMessage);
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

  /// Fetch list of conversations for current user
  Future<void> fetchUserConversations() async {
    if (_currentUser == null) {
      AppLogger.error('Cannot fetch conversations: No user set');
      return;
    }

    final result = await executeApiOperation(
      () => _repository.getUserConversations(_currentUser!.id.toString()),
      operationName: 'fetchUserConversations',
    );

    if (result != null) {
      _conversationIds = result;
      // Sort descending (newest first) - assuming IDs are incremental
      _conversationIds.sort((a, b) => b.compareTo(a));
      AppLogger.info('Loaded ${_conversationIds.length} conversations');
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

    // If we have Tu Vi chart data, use the fast analyze-json endpoint
    if (_currentChartData != null) {
      final analysisResult = await executeApiOperation(
        () => _repository.analyzeTuViJson(
          chartData: _currentChartData!,
          question: trimmedMessage,
        ),
        operationName: 'analyzeTuViJson',
        showLoading: false,
      );

      _setAiTyping(false);

      if (analysisResult != null) {
        // Convert analysis result to chat message
        final aiMessage = ChatMessageModel.ai(
          id: _generateId(),
          content: analysisResult.analysis,
          isDelivered: true,
          metadata: {
            'method': analysisResult.method,
            'processing_time': analysisResult.processingTime,
            'timestamp': analysisResult.timestamp,
          },
        );

        _messages.add(aiMessage);
        AppLogger.info('Received Tu Vi analysis (${analysisResult.processingTime})');
        notifyListeners();
        return true;
      }

      return false;
    }

    // Otherwise, use regular chat endpoint
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
    _currentChartData = null;
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
