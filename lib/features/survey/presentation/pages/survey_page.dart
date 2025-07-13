import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/survey_provider.dart';
import '../../data/models/survey_question_model.dart';
import '../widgets/survey_option_widget.dart';

/// Survey page that matches the Figma design
class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  @override
  void initState() {
    super.initState();
    // Initialize survey with demo data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SurveyProvider>().loadDemoSurvey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<SurveyProvider>(
          builder: (context, surveyProvider, child) {
            if (!surveyProvider.hasQuestions) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                ),
              );
            }

            return Column(
              children: [
                // Header with back button, close button, and progress
                _buildHeader(surveyProvider),
                
                // Content area
                Expanded(
                  child: _buildContent(surveyProvider),
                ),
                
                // Navigation controls
                _buildNavigationControls(surveyProvider),
                
                // Bottom indicator (home indicator)
                _buildBottomIndicator(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Build header section with navigation and progress
  Widget _buildHeader(SurveyProvider surveyProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Column(
        children: [
          // Navigation buttons row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => _handleBackButton(surveyProvider),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '←',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Close button
              GestureDetector(
                onTap: () => _handleCloseButton(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFCCCCCC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '×',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progress section
          Column(
            children: [
              // Progress text
              Text(
                surveyProvider.progressText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: surveyProvider.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build main content area
  Widget _buildContent(SurveyProvider surveyProvider) {
    final question = surveyProvider.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Question section
          _buildQuestionSection(question),
          
          const SizedBox(height: 48),
          
          // Options section
          Expanded(
            child: _buildOptionsSection(question, surveyProvider),
          ),
        ],
      ),
    );
  }

  /// Build question section
  Widget _buildQuestionSection(question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main question title
        Text(
          question.title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        
        const SizedBox(height: 3),
        
        // Question subtitle
        Text(
          question.subtitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF333333),
            height: 1.15,
          ),
        ),
        
        const SizedBox(height: 15),
        
        // Instruction text
        const Text(
          'Chọn tùy chọn mô tả tốt nhất',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
            height: 1.15,
          ),
        ),

        const SizedBox(height: 2),

        const Text(
          'tính cách và sở thích của bạn.',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF666666),
            height: 1.15,
          ),
        ),
      ],
    );
  }

  /// Build options section
  Widget _buildOptionsSection(question, SurveyProvider surveyProvider) {
    return ListView.separated(
      itemCount: question.options.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = surveyProvider.currentResponse?.selectedOptionIds.contains(option.id) ?? false;
        
        return SurveyOptionWidget(
          option: option,
          isSelected: isSelected,
          onTap: () => surveyProvider.selectOption(option.id),
        );
      },
    );
  }

  /// Build navigation controls
  Widget _buildNavigationControls(SurveyProvider surveyProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: GestureDetector(
              onTap: surveyProvider.isFirstQuestion ? null : () => surveyProvider.goToPreviousQuestion(),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Trước',
                    style: TextStyle(
                      fontSize: 16,
                      color: surveyProvider.isFirstQuestion ? const Color(0xFFCCCCCC) : const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Next button
          Expanded(
            child: GestureDetector(
              onTap: surveyProvider.isCurrentQuestionAnswered ? () => _handleNextButton(surveyProvider) : null,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: surveyProvider.isCurrentQuestionAnswered ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    surveyProvider.isLastQuestion ? 'Hoàn thành' : 'Tiếp theo',
                    style: TextStyle(
                      fontSize: 16,
                      color: surveyProvider.isCurrentQuestionAnswered ? Colors.white : const Color(0xFF999999),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build bottom indicator
  Widget _buildBottomIndicator() {
    return Container(
      height: 56,
      color: Colors.white,
      child: Center(
        child: Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
      ),
    );
  }

  /// Handle back button press
  void _handleBackButton(SurveyProvider surveyProvider) {
    if (surveyProvider.isFirstQuestion) {
      context.pop();
    } else {
      surveyProvider.goToPreviousQuestion();
    }
  }

  /// Handle close button press
  void _handleCloseButton() {
    context.pop();
  }

  /// Handle next button press
  void _handleNextButton(SurveyProvider surveyProvider) {
    if (surveyProvider.isLastQuestion) {
      // Complete survey
      _completeSurvey(surveyProvider);
    } else {
      surveyProvider.goToNextQuestion();
    }
  }

  /// Complete survey and navigate
  void _completeSurvey(SurveyProvider surveyProvider) {
    // TODO: Submit survey data to API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Khảo sát đã hoàn thành thành công!'),
        backgroundColor: AppColors.success,
      ),
    );
    
    // Navigate to home or next screen
    context.go(AppConstants.homeRoute);
  }
}
