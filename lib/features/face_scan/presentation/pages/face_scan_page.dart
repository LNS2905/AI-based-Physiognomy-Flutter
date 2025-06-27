import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../providers/face_scan_provider.dart';
import '../widgets/face_analysis_demo.dart';
import '../widgets/face_scan_tab_navigation.dart';
import '../widgets/face_scan_content.dart';

/// Face scan screen following the exact Figma design
class FaceScanPage extends StatefulWidget {
  const FaceScanPage({super.key});

  @override
  State<FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<FaceScanPage> {
  @override
  void initState() {
    super.initState();
    // Initialize provider if needed
    // Note: Commented out loadScanHistory() since we don't have a real API yet
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<FaceScanProvider>().loadScanHistory();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColors.surfaceVariant.withOpacity(0.3),
              Colors.white,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                _buildHeader(context),

                const SizedBox(height: 12),

                // Main Content Section
                _buildMainContent(),

                const SizedBox(height: 16),

                // Call-to-Action Text
                _buildCallToActionText(),

                const SizedBox(height: 16),

                // Tab Navigation
                _buildTabNavigation(),

                const SizedBox(height: 12),

                // Tab Content
                _buildTabContent(),

                const SizedBox(height: 20),

                // Bottom Navigation Placeholder
                _buildBottomNavigation(),

                const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),

          // Top bar with back button and title
          SizedBox(
            height: 40,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.2)],
                      ),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Face Scan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Large title with gradient
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ).createShader(bounds),
            child: const Text(
              'FACE SCAN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: [
          const Text(
            'AI PHYSIOGNOMY ANALYSIS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          const FaceAnalysisDemo(),
        ],
      ),
    );
  }

  Widget _buildCallToActionText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Discover your personality',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'through facial analysis!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Consumer<FaceScanProvider>(
        builder: (context, provider, child) {
          return FaceScanTabNavigation(
            selectedTab: provider.selectedTab,
            onTabSelected: provider.setSelectedTab,
          );
        },
      ),
    );
  }

  Widget _buildTabContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Consumer<FaceScanProvider>(
        builder: (context, provider, child) {
          switch (provider.selectedTab) {
            case 'face_scan':
              return FaceScanContent(
                onBeginAnalysis: _handleBeginAnalysis,
                isLoading: provider.isLoading,
              );
            case 'upload_photo':
              return _buildUploadPhotoContent();
            case 'user_guide':
              return _buildUserGuideContent();
            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildUploadPhotoContent() {
    return Container(
      width: 376,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.surfaceVariant.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Upload Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose a photo from your gallery\nfor analysis',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserGuideContent() {
    return Container(
      width: 376,
      height: 100,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.surfaceVariant.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.help_outline,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'User Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Learn how to get the best\nanalysis results',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home_outlined, isActive: false),
          _buildBottomNavItem(Icons.search_outlined, isActive: false),
          _buildBottomNavItem(Icons.face_retouching_natural, isActive: true),
          _buildBottomNavItem(Icons.person_outline, isActive: false),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, {required bool isActive}) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              )
            : null,
        color: isActive ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        size: isActive ? 22 : 20,
        color: isActive ? Colors.white : AppColors.textSecondary,
      ),
    );
  }

  void _handleBeginAnalysis() async {
    final provider = context.read<FaceScanProvider>();

    try {
      // Check camera permissions first
      final hasPermissions = await provider.checkCameraPermissions();

      if (!hasPermissions) {
        // Request permissions
        final granted = await provider.requestCameraPermissions();

        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Camera permission is required for face scanning'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // Initialize camera service if needed
      if (!provider.isCameraInitialized) {
        provider.setLoading(true);
        final initialized = await provider.initializeCamera();
        provider.setLoading(false);

        if (!initialized) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to initialize camera. Please try again.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // Navigate to camera screen
      if (mounted) {
        context.push('/camera');
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, showSnackBar: true);
        provider.setLoading(false);
      }
    }
  }
}
