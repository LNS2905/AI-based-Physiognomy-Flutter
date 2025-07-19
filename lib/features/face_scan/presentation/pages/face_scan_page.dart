import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../providers/face_scan_provider.dart';
import '../widgets/face_analysis_demo.dart';
import '../widgets/face_scan_tab_navigation.dart';
import '../widgets/face_scan_content.dart';
import 'analysis_results_page.dart';

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
    // Set default tab to face_scan when entering face scan screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceScanProvider>().setSelectedTab('face_scan');
    });
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
                const Expanded(
                  child: Text(
                    'Quét khuôn mặt',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // User Guide button
                GestureDetector(
                  onTap: () => context.push('/user-guide'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.help_outline,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
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
              'QUÉT KHUÔN MẶT',
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
            'PHÂN TÍCH TƯỚNG HỌC AI',
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
              Flexible(
                child: Text(
                  'Khám phá tính cách của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'thông qua phân tích khuôn mặt!',
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
    return GestureDetector(
      onTap: _handleUploadPhoto,
      child: Container(
        width: 376,
        height: 80,
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
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(width: 12),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tải ảnh lên',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Chọn một ảnh từ thư viện của bạn để phân tích',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserGuideContent() {
    return GestureDetector(
      onTap: () => context.push('/user-guide'),
      child: Container(
        width: 376,
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              AppColors.surfaceVariant.withValues(alpha: 0.3),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.help_outline,
                      size: 20,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Hướng dẫn sử dụng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Hướng dẫn từng bước để quét khuôn mặt',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),

            // Tap to view indicator
            Positioned(
              bottom: 6,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Nhấn để xem',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
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
      // Initialize camera service if needed
      if (!provider.isCameraInitialized) {
        provider.setLoading(true);
        final initialized = await provider.initializeCamera();
        provider.setLoading(false);

        if (!initialized) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể khởi tạo camera. Vui lòng thử lại.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      // Navigate to camera screen and wait for result
      if (mounted) {
        final result = await context.push<CloudinaryAnalysisResponseModel>('/camera');

        // Check if we got a successful result
        if (result != null && mounted) {
          // Update provider state with the result
          provider.setCurrentCloudinaryResult(result);
          provider.setSelectedImagePath(''); // Clear selected path since we're using Cloudinary result

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh đã được chụp và phân tích thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Show analysis results
          _showAnalysisResults(provider);
        } else if (mounted) {
          // Only show error if result is explicitly null (not just user backing out)
          // We can check if there was actually an error by checking provider state
          AppLogger.info('Camera returned without result - user may have cancelled');
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, showSnackBar: true);
        provider.setLoading(false);
      }
    }
  }

  /// Handle upload photo button tap
  Future<void> _handleUploadPhoto() async {
    final provider = context.read<FaceScanProvider>();

    try {
      AppLogger.info('Upload photo button tapped');

      // Pick image and analyze
      final success = await provider.pickImageAndAnalyze();

      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh đã được tải lên và phân tích thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to results page or show results
          _showAnalysisResults(provider);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tải lên và phân tích ảnh. Vui lòng thử lại.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to handle upload photo', e);
      if (mounted) {
        ErrorHandler.handleError(context, e, showSnackBar: true);
      }
    }
  }

  /// Show analysis results
  void _showAnalysisResults(FaceScanProvider provider) {
    // Check for Cloudinary results first (new format)
    final cloudinaryResult = provider.currentCloudinaryResult;

    if (cloudinaryResult != null) {
      // Navigate to dedicated results page with Cloudinary data
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AnalysisResultsPage(
            analysisResponse: cloudinaryResult,
            annotatedImagePath: cloudinaryResult.annotatedImageUrl,
            reportImagePath: cloudinaryResult.annotatedImageUrl, // Use annotated image URL for both
          ),
        ),
      );
    } else {
      // Fallback to legacy analysis data
      final analysisData = provider.analysisData;
      final annotatedImagePath = provider.annotatedImagePath;
      final reportImagePath = provider.reportImagePath;

      if (analysisData != null) {
        // Navigate to dedicated results page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisResultsPage(
              legacyAnalysisData: analysisData,
              annotatedImagePath: annotatedImagePath,
              reportImagePath: reportImagePath,
            ),
          ),
        );
      } else {
        // Show error dialog if no analysis data
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi phân tích'),
            content: const Text('Không có dữ liệu phân tích. Vui lòng thử lại.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
