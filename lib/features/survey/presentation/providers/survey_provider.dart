import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/survey_question_model.dart';
import '../../data/models/survey_response_model.dart';

/// Survey provider for managing survey state and responses
class SurveyProvider extends BaseProvider {
  // Survey data
  List<SurveyQuestionModel> _questions = [];
  final Map<String, SurveyResponseModel> _responses = <String, SurveyResponseModel>{};
  int _currentQuestionIndex = 0;
  DateTime? _surveyStartTime;
  
  // Getters
  List<SurveyQuestionModel> get questions => _questions;
  Map<String, SurveyResponseModel> get responses => _responses;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get hasQuestions => _questions.isNotEmpty;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  bool get isLastQuestion => _currentQuestionIndex == _questions.length - 1;
  double get progress => hasQuestions ? (_currentQuestionIndex + 1) / _questions.length : 0.0;
  DateTime? get surveyStartTime => _surveyStartTime;
  
  /// Get current question
  SurveyQuestionModel? get currentQuestion {
    if (!hasQuestions || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }
  
  /// Get response for current question
  SurveyResponseModel? get currentResponse {
    final question = currentQuestion;
    if (question == null) return null;
    return _responses[question.id];
  }
  
  /// Check if current question is answered
  bool get isCurrentQuestionAnswered {
    final response = currentResponse;
    return response != null && response.selectedOptionIds.isNotEmpty;
  }
  
  /// Initialize survey with questions
  void initializeSurvey(List<SurveyQuestionModel> questions) {
    _questions = questions;
    _responses.clear();
    _currentQuestionIndex = 0;
    _surveyStartTime = DateTime.now();
    
    AppLogger.logStateChange(
      runtimeType.toString(),
      'initializeSurvey',
      'questions: ${questions.length}',
    );
    notifyListeners();
  }
  
  /// Load survey questions for AI Physiognomy app
  void loadDemoSurvey() {
    final demoQuestions = [
      SurveyQuestionModel(
        id: 'personality_type',
        title: 'Loại tính cách nào',
        subtitle: 'mô tả bạn tốt nhất?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'extrovert',
            text: 'Hướng ngoại - Cởi mở và xã hội',
            value: 'extrovert',
          ),
          const SurveyOptionModel(
            id: 'introvert',
            text: 'Hướng nội - Yên tĩnh và suy tư',
            value: 'introvert',
          ),
          const SurveyOptionModel(
            id: 'ambivert',
            text: 'Lưỡng hướng - Kết hợp cả hai',
            value: 'ambivert',
          ),
          const SurveyOptionModel(
            id: 'depends',
            text: 'Tùy thuộc vào tình huống',
            value: 'depends',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'lifestyle_preference',
        title: 'Điều gì mô tả',
        subtitle: 'sở thích lối sống của bạn?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'active_adventurous',
            text: 'Năng động và thích phiêu lưu',
            value: 'active_adventurous',
          ),
          const SurveyOptionModel(
            id: 'calm_peaceful',
            text: 'Bình tĩnh và yên bình',
            value: 'calm_peaceful',
          ),
          const SurveyOptionModel(
            id: 'creative_artistic',
            text: 'Sáng tạo và nghệ thuật',
            value: 'creative_artistic',
          ),
          const SurveyOptionModel(
            id: 'intellectual_analytical',
            text: 'Trí tuệ và phân tích',
            value: 'intellectual_analytical',
          ),
          const SurveyOptionModel(
            id: 'social_collaborative',
            text: 'Xã hội và hợp tác',
            value: 'social_collaborative',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'decision_making',
        title: 'Bạn thường',
        subtitle: 'đưa ra quyết định quan trọng như thế nào?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'logical_analysis',
            text: 'Thông qua phân tích logic',
            value: 'logical_analysis',
          ),
          const SurveyOptionModel(
            id: 'gut_feeling',
            text: 'Dựa trên cảm giác trực giác',
            value: 'gut_feeling',
          ),
          const SurveyOptionModel(
            id: 'seek_advice',
            text: 'Tìm kiếm lời khuyên từ người khác',
            value: 'seek_advice',
          ),
          const SurveyOptionModel(
            id: 'research_thoroughly',
            text: 'Nghiên cứu kỹ lưỡng trước',
            value: 'research_thoroughly',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'stress_response',
        title: 'Bạn xử lý',
        subtitle: 'các tình huống căng thẳng như thế nào?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'stay_calm',
            text: 'Giữ bình tĩnh và điềm đạm',
            value: 'stay_calm',
          ),
          const SurveyOptionModel(
            id: 'take_action',
            text: 'Hành động ngay lập tức',
            value: 'take_action',
          ),
          const SurveyOptionModel(
            id: 'seek_support',
            text: 'Tìm kiếm sự hỗ trợ từ người khác',
            value: 'seek_support',
          ),
          const SurveyOptionModel(
            id: 'need_time',
            text: 'Cần thời gian để xử lý',
            value: 'need_time',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'communication_style',
        title: 'Phong cách giao tiếp',
        subtitle: 'ưa thích của bạn là gì?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'direct_honest',
            text: 'Trực tiếp và thành thật',
            value: 'direct_honest',
          ),
          const SurveyOptionModel(
            id: 'diplomatic_tactful',
            text: 'Ngoại giao và khéo léo',
            value: 'diplomatic_tactful',
          ),
          const SurveyOptionModel(
            id: 'expressive_emotional',
            text: 'Biểu cảm và cảm xúc',
            value: 'expressive_emotional',
          ),
          const SurveyOptionModel(
            id: 'thoughtful_measured',
            text: 'Suy nghĩ và cân nhắc',
            value: 'thoughtful_measured',
          ),
        ],
      ),
    ];

    initializeSurvey(demoQuestions);
  }
  
  /// Answer current question
  void answerQuestion(List<String> selectedOptionIds, {String? textResponse}) {
    final question = currentQuestion;
    if (question == null) return;
    
    final response = SurveyResponseModel(
      questionId: question.id,
      selectedOptionIds: selectedOptionIds,
      textResponse: textResponse,
      timestamp: DateTime.now(),
    );
    
    _responses[question.id] = response;
    
    AppLogger.logStateChange(
      runtimeType.toString(),
      'answerQuestion',
      'questionId: ${question.id}, options: $selectedOptionIds',
    );
    notifyListeners();
  }
  
  /// Select single option for current question
  void selectOption(String optionId) {
    answerQuestion([optionId]);
  }
  
  /// Toggle option selection for multiple choice questions
  void toggleOption(String optionId) {
    final currentResponse = this.currentResponse;
    List<String> selectedOptions = [];
    
    if (currentResponse != null) {
      selectedOptions = List.from(currentResponse.selectedOptionIds);
    }
    
    if (selectedOptions.contains(optionId)) {
      selectedOptions.remove(optionId);
    } else {
      selectedOptions.add(optionId);
    }
    
    answerQuestion(selectedOptions);
  }
  
  /// Go to next question
  bool goToNextQuestion() {
    if (isLastQuestion) return false;
    
    _currentQuestionIndex++;
    AppLogger.logStateChange(
      runtimeType.toString(),
      'goToNextQuestion',
      'index: $_currentQuestionIndex',
    );
    notifyListeners();
    return true;
  }
  
  /// Go to previous question
  bool goToPreviousQuestion() {
    if (isFirstQuestion) return false;
    
    _currentQuestionIndex--;
    AppLogger.logStateChange(
      runtimeType.toString(),
      'goToPreviousQuestion',
      'index: $_currentQuestionIndex',
    );
    notifyListeners();
    return true;
  }
  
  /// Go to specific question by index
  void goToQuestion(int index) {
    if (index >= 0 && index < _questions.length) {
      _currentQuestionIndex = index;
      AppLogger.logStateChange(
        runtimeType.toString(),
        'goToQuestion',
        'index: $index',
      );
      notifyListeners();
    }
  }
  
  /// Check if survey is completed
  bool get isSurveyCompleted {
    if (!hasQuestions) return false;
    
    for (final question in _questions) {
      if (question.isRequired && !_responses.containsKey(question.id)) {
        return false;
      }
    }
    return true;
  }
  
  /// Get survey submission data
  SurveySubmissionModel? getSurveySubmission(String userId) {
    if (!isSurveyCompleted || _surveyStartTime == null) return null;
    
    return SurveySubmissionModel(
      surveyId: 'demo_survey_v1',
      userId: userId,
      responses: _responses.values.toList(),
      startTime: _surveyStartTime!,
      completionTime: DateTime.now(),
      isCompleted: true,
    );
  }
  
  /// Reset survey state
  void resetSurvey() {
    _questions.clear();
    _responses.clear();
    _currentQuestionIndex = 0;
    _surveyStartTime = null;
    
    AppLogger.logStateChange(runtimeType.toString(), 'resetSurvey', null);
    notifyListeners();
  }
  
  /// Get progress text for display
  String get progressText {
    if (!hasQuestions) return '';
    return 'Câu hỏi ${_currentQuestionIndex + 1} / $totalQuestions';
  }
}
