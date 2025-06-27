import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/survey_question_model.dart';
import '../../data/models/survey_response_model.dart';

/// Survey provider for managing survey state and responses
class SurveyProvider extends BaseProvider {
  // Survey data
  List<SurveyQuestionModel> _questions = [];
  Map<String, SurveyResponseModel> _responses = {};
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
        title: 'Which personality type',
        subtitle: 'describes you best?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'extrovert',
            text: 'Extrovert - Outgoing and social',
            value: 'extrovert',
          ),
          const SurveyOptionModel(
            id: 'introvert',
            text: 'Introvert - Quiet and reflective',
            value: 'introvert',
          ),
          const SurveyOptionModel(
            id: 'ambivert',
            text: 'Ambivert - Mix of both',
            value: 'ambivert',
          ),
          const SurveyOptionModel(
            id: 'depends',
            text: 'Depends on the situation',
            value: 'depends',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'lifestyle_preference',
        title: 'What describes your',
        subtitle: 'lifestyle preference?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'active_adventurous',
            text: 'Active and adventurous',
            value: 'active_adventurous',
          ),
          const SurveyOptionModel(
            id: 'calm_peaceful',
            text: 'Calm and peaceful',
            value: 'calm_peaceful',
          ),
          const SurveyOptionModel(
            id: 'creative_artistic',
            text: 'Creative and artistic',
            value: 'creative_artistic',
          ),
          const SurveyOptionModel(
            id: 'intellectual_analytical',
            text: 'Intellectual and analytical',
            value: 'intellectual_analytical',
          ),
          const SurveyOptionModel(
            id: 'social_collaborative',
            text: 'Social and collaborative',
            value: 'social_collaborative',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'decision_making',
        title: 'How do you typically',
        subtitle: 'make important decisions?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'logical_analysis',
            text: 'Through logical analysis',
            value: 'logical_analysis',
          ),
          const SurveyOptionModel(
            id: 'gut_feeling',
            text: 'Based on gut feeling',
            value: 'gut_feeling',
          ),
          const SurveyOptionModel(
            id: 'seek_advice',
            text: 'Seek advice from others',
            value: 'seek_advice',
          ),
          const SurveyOptionModel(
            id: 'research_thoroughly',
            text: 'Research thoroughly first',
            value: 'research_thoroughly',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'stress_response',
        title: 'How do you handle',
        subtitle: 'stressful situations?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'stay_calm',
            text: 'Stay calm and composed',
            value: 'stay_calm',
          ),
          const SurveyOptionModel(
            id: 'take_action',
            text: 'Take immediate action',
            value: 'take_action',
          ),
          const SurveyOptionModel(
            id: 'seek_support',
            text: 'Seek support from others',
            value: 'seek_support',
          ),
          const SurveyOptionModel(
            id: 'need_time',
            text: 'Need time to process',
            value: 'need_time',
          ),
        ],
      ),

      SurveyQuestionModel(
        id: 'communication_style',
        title: 'What is your preferred',
        subtitle: 'communication style?',
        type: SurveyQuestionType.singleChoice,
        options: [
          const SurveyOptionModel(
            id: 'direct_honest',
            text: 'Direct and honest',
            value: 'direct_honest',
          ),
          const SurveyOptionModel(
            id: 'diplomatic_tactful',
            text: 'Diplomatic and tactful',
            value: 'diplomatic_tactful',
          ),
          const SurveyOptionModel(
            id: 'expressive_emotional',
            text: 'Expressive and emotional',
            value: 'expressive_emotional',
          ),
          const SurveyOptionModel(
            id: 'thoughtful_measured',
            text: 'Thoughtful and measured',
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
    return 'Question ${_currentQuestionIndex + 1} of $totalQuestions';
  }
}
