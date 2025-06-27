/// Survey response model
class SurveyResponseModel {
  final String questionId;
  final List<String> selectedOptionIds;
  final String? textResponse;
  final DateTime timestamp;

  const SurveyResponseModel({
    required this.questionId,
    required this.selectedOptionIds,
    this.textResponse,
    required this.timestamp,
  });

  factory SurveyResponseModel.fromJson(Map<String, dynamic> json) {
    return SurveyResponseModel(
      questionId: json['questionId'] as String,
      selectedOptionIds: (json['selectedOptionIds'] as List<dynamic>)
          .map((id) => id as String)
          .toList(),
      textResponse: json['textResponse'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'selectedOptionIds': selectedOptionIds,
      'textResponse': textResponse,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  SurveyResponseModel copyWith({
    String? questionId,
    List<String>? selectedOptionIds,
    String? textResponse,
    DateTime? timestamp,
  }) {
    return SurveyResponseModel(
      questionId: questionId ?? this.questionId,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
      textResponse: textResponse ?? this.textResponse,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveyResponseModel &&
        other.questionId == questionId &&
        other.selectedOptionIds.length == selectedOptionIds.length &&
        other.selectedOptionIds.every((id) => selectedOptionIds.contains(id)) &&
        other.textResponse == textResponse &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(questionId, selectedOptionIds, textResponse, timestamp);
  }

  @override
  String toString() {
    return 'SurveyResponseModel(questionId: $questionId, selectedOptionIds: $selectedOptionIds, textResponse: $textResponse, timestamp: $timestamp)';
  }
}

/// Complete survey submission model
class SurveySubmissionModel {
  final String surveyId;
  final String userId;
  final List<SurveyResponseModel> responses;
  final DateTime startTime;
  final DateTime? completionTime;
  final bool isCompleted;

  const SurveySubmissionModel({
    required this.surveyId,
    required this.userId,
    required this.responses,
    required this.startTime,
    this.completionTime,
    this.isCompleted = false,
  });

  factory SurveySubmissionModel.fromJson(Map<String, dynamic> json) {
    return SurveySubmissionModel(
      surveyId: json['surveyId'] as String,
      userId: json['userId'] as String,
      responses: (json['responses'] as List<dynamic>)
          .map((response) => SurveyResponseModel.fromJson(response as Map<String, dynamic>))
          .toList(),
      startTime: DateTime.parse(json['startTime'] as String),
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'] as String)
          : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveyId': surveyId,
      'userId': userId,
      'responses': responses.map((response) => response.toJson()).toList(),
      'startTime': startTime.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  SurveySubmissionModel copyWith({
    String? surveyId,
    String? userId,
    List<SurveyResponseModel>? responses,
    DateTime? startTime,
    DateTime? completionTime,
    bool? isCompleted,
  }) {
    return SurveySubmissionModel(
      surveyId: surveyId ?? this.surveyId,
      userId: userId ?? this.userId,
      responses: responses ?? this.responses,
      startTime: startTime ?? this.startTime,
      completionTime: completionTime ?? this.completionTime,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveySubmissionModel &&
        other.surveyId == surveyId &&
        other.userId == userId &&
        other.responses.length == responses.length &&
        other.startTime == startTime &&
        other.completionTime == completionTime &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(surveyId, userId, responses, startTime, completionTime, isCompleted);
  }

  @override
  String toString() {
    return 'SurveySubmissionModel(surveyId: $surveyId, userId: $userId, responses: ${responses.length}, startTime: $startTime, completionTime: $completionTime, isCompleted: $isCompleted)';
  }
}
