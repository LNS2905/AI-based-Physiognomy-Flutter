import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/user_guide_step_card.dart';

/// User Guide screen for face scanning feature
/// Displays step-by-step instructions following the Figma design
class UserGuidePage extends StatefulWidget {
  const UserGuidePage({super.key});

  @override
  State<UserGuidePage> createState() => _UserGuidePageState();
}

class _UserGuidePageState extends State<UserGuidePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: AppConstants.mediumAnimationDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                _buildHeader(context),

                const SizedBox(height: 20),

                // Steps Section
                _buildStepsSection(),

                const SizedBox(height: 40),

                // Bottom Navigation Placeholder
                _buildBottomNavigation(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          bottom: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Top navigation bar
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Title
              const Text(
                'Guild',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Main title
          const Text(
            'USER GUIDE',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // Step 1
          UserGuideStepCard(
            stepNumber: 1,
            title: 'Take a selfie',
            description: 'Person taking selfie\nwith phone camera',
            imagePlaceholder: '[SELFIE IMAGE]',
            onViewDetails: () => _showStepDetails(context, 1),
          ),

          const SizedBox(height: 30),

          // Step 2
          UserGuideStepCard(
            stepNumber: 2,
            title: 'Facial Area Selection',
            description: 'Facial area selection\nand detection interface',
            imagePlaceholder: '[FACE ANALYSIS]',
            onViewDetails: () => _showStepDetails(context, 2),
          ),

          const SizedBox(height: 30),

          // Step 3
          UserGuideStepCard(
            stepNumber: 3,
            title: 'AI Analysis Results',
            description: 'Physiognomy analysis\nresults and insights',
            imagePlaceholder: '[AI ANALYSIS]',
            onViewDetails: () => _showStepDetails(context, 3),
          ),

          const SizedBox(height: 30),

          // Step 4
          UserGuideStepCard(
            stepNumber: 4,
            title: 'Expert Consultation',
            description: 'Professional physiognomy\nexpert consultation',
            imagePlaceholder: '[EXPERT CONSULTATION]',
            onViewDetails: () => _showStepDetails(context, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home_outlined, 'Home'),
          _buildBottomNavItem(Icons.search_outlined, 'Search'),
          _buildBottomNavItem(Icons.face_retouching_natural, 'Scan', isActive: true),
          _buildBottomNavItem(Icons.person_outline, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showStepDetails(BuildContext context, int stepNumber) {
    final stepDetails = _getStepDetails(stepNumber);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Step $stepNumber: ${stepDetails['title'] ?? 'Unknown Step'}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    stepDetails['details'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getStepDetails(int stepNumber) {
    switch (stepNumber) {
      case 1:
        return {
          'title': 'Take a selfie',
          'details': '''• Position your face in the center of the camera frame
• Ensure good lighting - natural light works best
• Keep your face straight and look directly at the camera
• Remove glasses, hats, or anything covering your face
• Make sure your entire face is visible in the frame
• Hold the phone steady and avoid blurry photos
• Take the photo in a neutral expression for best results''',
        };
      case 2:
        return {
          'title': 'Facial Area Selection',
          'details': '''• The AI will automatically detect your face in the image
• Key facial features will be highlighted and analyzed
• Ensure all important facial areas are clearly visible
• The system will identify eyes, nose, mouth, and facial contours
• If detection fails, retake the photo with better lighting
• The analysis focuses on facial proportions and symmetry
• This step ensures accurate physiognomy analysis''',
        };
      case 3:
        return {
          'title': 'AI Analysis Results',
          'details': '''• Advanced AI algorithms analyze your facial features
• The system examines facial proportions, symmetry, and characteristics
• Results include personality insights based on physiognomy principles
• Analysis covers traits like confidence, creativity, and social tendencies
• Results are presented in an easy-to-understand format
• Each trait comes with detailed explanations
• The analysis is based on established physiognomy research''',
        };
      case 4:
        return {
          'title': 'Expert Consultation',
          'details': '''• Connect with certified physiognomy experts
• Get professional interpretation of your analysis results
• Ask questions about specific traits or characteristics
• Receive personalized advice and insights
• Schedule one-on-one consultation sessions
• Expert guidance helps you understand results better
• Professional validation of AI analysis findings''',
        };
      default:
        return {'title': 'Unknown Step', 'details': 'Step details not available.'};
    }
  }
}
