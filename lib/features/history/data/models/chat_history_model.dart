import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../ai_conversation/data/models/conversation_model.dart';
import '../../../ai_conversation/data/models/chat_message_model.dart';
import 'history_item_model.dart';

part 'chat_history_model.g.dart';

/// Chat conversation history item
@JsonSerializable()
class ChatHistoryModel extends HistoryItemModel {
  final ConversationModel conversation;
  final int messageCount;
  final String lastMessagePreview;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ChatHistoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.updatedAt,
    required this.conversation,
    required this.messageCount,
    required this.lastMessagePreview,
    required this.lastMessageTime,
    this.unreadCount = 0,
    super.metadata,
    super.thumbnailUrl,
    super.isFavorite,
    super.tags,
  }) : super(type: HistoryItemType.chatConversation);

  /// Create from conversation
  factory ChatHistoryModel.fromConversation({
    required String id,
    required ConversationModel conversation,
    Map<String, dynamic>? metadata,
  }) {
    final messageCount = conversation.messages.length;
    final lastMessage = conversation.lastMessage;
    final lastMessagePreview = lastMessage?.content ?? 'Chưa có tin nhắn';
    final lastMessageTime = lastMessage?.timestamp ?? conversation.createdAt;
    final unreadCount = conversation.unreadCount;

    // Generate title based on conversation content
    String title = conversation.title;
    if (title == 'New Conversation' && lastMessage != null) {
      // Use first user message as title
      final firstUserMessage = conversation.messages
          .where((msg) => msg.sender == MessageSender.user)
          .firstOrNull;
      if (firstUserMessage != null) {
        title = firstUserMessage.content.length > 30
            ? '${firstUserMessage.content.substring(0, 30)}...'
            : firstUserMessage.content;
      }
    }

    // Generate description
    String description;
    if (messageCount == 0) {
      description = 'Cuộc trò chuyện mới chưa có tin nhắn';
    } else if (messageCount == 1) {
      description = '1 tin nhắn';
    } else {
      description = '$messageCount tin nhắn';
    }

    if (unreadCount > 0) {
      description += ' • $unreadCount chưa đọc';
    }

    return ChatHistoryModel(
      id: id,
      title: title,
      description: description,
      createdAt: conversation.createdAt,
      updatedAt: conversation.updatedAt,
      conversation: conversation,
      messageCount: messageCount,
      lastMessagePreview: lastMessagePreview,
      lastMessageTime: lastMessageTime,
      unreadCount: unreadCount,
      metadata: metadata,
      tags: ['chat', 'conversation', if (unreadCount > 0) 'unread'],
    );
  }

  /// Get conversation duration
  String get conversationDuration {
    final duration = conversation.updatedAt.difference(conversation.createdAt);
    
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} phút';
    } else {
      return 'Vài giây';
    }
  }

  /// Get last message formatted time
  String get lastMessageFormattedTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Vừa xong';
        }
        return '${difference.inMinutes}p';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${lastMessageTime.day}/${lastMessageTime.month}';
    }
  }

  /// Get conversation participants count
  int get participantCount {
    final senders = conversation.messages
        .map((msg) => msg.sender)
        .toSet();
    return senders.length;
  }

  /// Check if conversation is active (has recent messages)
  bool get isActive {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);
    return difference.inDays < 7; // Active if last message within 7 days
  }

  /// Get conversation topics/keywords
  List<String> get conversationTopics {
    final topics = <String>[];
    
    // Extract keywords from messages
    for (final message in conversation.messages) {
      if (message.sender == MessageSender.user) {
        final content = message.content.toLowerCase();
        
        // Check for common topics
        if (content.contains('khuôn mặt') || content.contains('face')) {
          topics.add('khuôn mặt');
        }
        if (content.contains('vân tay') || content.contains('palm')) {
          topics.add('vân tay');
        }
        if (content.contains('tướng học') || content.contains('physiognomy')) {
          topics.add('tướng học');
        }
        if (content.contains('phân tích') || content.contains('analysis')) {
          topics.add('phân tích');
        }
        if (content.contains('kết quả') || content.contains('result')) {
          topics.add('kết quả');
        }
      }
    }
    
    return topics.toSet().toList();
  }

  @override
  ChatHistoryModel copyWith({
    String? id,
    String? title,
    String? description,
    HistoryItemType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationModel? conversation,
    int? messageCount,
    String? lastMessagePreview,
    DateTime? lastMessageTime,
    int? unreadCount,
    Map<String, dynamic>? metadata,
    String? thumbnailUrl,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return ChatHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversation: conversation ?? this.conversation,
      messageCount: messageCount ?? this.messageCount,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      metadata: metadata ?? this.metadata,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        conversation,
        messageCount,
        lastMessagePreview,
        lastMessageTime,
        unreadCount,
      ];

  /// JSON serialization
  factory ChatHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$ChatHistoryModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChatHistoryModelToJson(this);
}

/// History filter options
enum HistoryFilter {
  all,
  faceAnalysis,
  palmAnalysis,
  chatConversation,
  favorites,
  recent,
  thisWeek,
  thisMonth,
}

/// History sort options
enum HistorySort {
  newest,
  oldest,
  alphabetical,
  mostUsed,
  favorites,
}

/// History filter and sort configuration
@JsonSerializable()
class HistoryFilterConfig extends Equatable {
  final HistoryFilter filter;
  final HistorySort sort;
  final String? searchQuery;
  final List<String> tags;
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const HistoryFilterConfig({
    this.filter = HistoryFilter.all,
    this.sort = HistorySort.newest,
    this.searchQuery,
    this.tags = const [],
    this.dateFrom,
    this.dateTo,
  });

  /// Check if any filters are active
  bool get hasActiveFilters {
    return filter != HistoryFilter.all ||
           searchQuery?.isNotEmpty == true ||
           tags.isNotEmpty ||
           dateFrom != null ||
           dateTo != null;
  }

  /// Get filter display name
  String get filterDisplayName {
    switch (filter) {
      case HistoryFilter.all:
        return 'Tất cả';
      case HistoryFilter.faceAnalysis:
        return 'Phân tích khuôn mặt';
      case HistoryFilter.palmAnalysis:
        return 'Phân tích vân tay';
      case HistoryFilter.chatConversation:
        return 'Trò chuyện AI';
      case HistoryFilter.favorites:
        return 'Yêu thích';
      case HistoryFilter.recent:
        return 'Gần đây';
      case HistoryFilter.thisWeek:
        return 'Tuần này';
      case HistoryFilter.thisMonth:
        return 'Tháng này';
    }
  }

  /// Get sort display name
  String get sortDisplayName {
    switch (sort) {
      case HistorySort.newest:
        return 'Mới nhất';
      case HistorySort.oldest:
        return 'Cũ nhất';
      case HistorySort.alphabetical:
        return 'Theo tên';
      case HistorySort.mostUsed:
        return 'Sử dụng nhiều';
      case HistorySort.favorites:
        return 'Yêu thích';
    }
  }

  HistoryFilterConfig copyWith({
    HistoryFilter? filter,
    HistorySort? sort,
    String? searchQuery,
    List<String>? tags,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) {
    return HistoryFilterConfig(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
    );
  }

  @override
  List<Object?> get props => [
        filter,
        sort,
        searchQuery,
        tags,
        dateFrom,
        dateTo,
      ];

  /// JSON serialization
  factory HistoryFilterConfig.fromJson(Map<String, dynamic> json) =>
      _$HistoryFilterConfigFromJson(json);

  Map<String, dynamic> toJson() => _$HistoryFilterConfigToJson(this);
}
