import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat_start_model.g.dart';

/// Chat start request model
@JsonSerializable()
class ChatStartRequest extends Equatable {
  @JsonKey(name: 'user_id')
  final int userId;
  @JsonKey(name: 'chart_id')
  final int? chartId;

  const ChatStartRequest({
    required this.userId,
    this.chartId,
  });

  /// JSON serialization
  factory ChatStartRequest.fromJson(Map<String, dynamic> json) =>
      _$ChatStartRequestFromJson(json);

  Map<String, dynamic> toJson() => _$ChatStartRequestToJson(this);

  @override
  List<Object?> get props => [userId, chartId];
}

/// Chat start response model
@JsonSerializable()
class ChatStartResponse extends Equatable {
  @JsonKey(name: 'conversation_id')
  final int conversationId;
  final String? title;
  final DateTime? createdAt;
  final Map<String, dynamic>? metadata;

  const ChatStartResponse({
    required this.conversationId,
    this.title,
    this.createdAt,
    this.metadata,
  });

  /// JSON serialization
  factory ChatStartResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatStartResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ChatStartResponseToJson(this);

  @override
  List<Object?> get props => [conversationId, title, createdAt, metadata];
}
