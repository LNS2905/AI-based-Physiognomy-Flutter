import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/fixed_bottom_navigation.dart';
import '../../../../core/widgets/standard_back_button.dart';
import '../../../../core/enums/loading_state.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../providers/face_scan_provider.dart';
import '../widgets/face_analysis_demo.dart';
import '../widgets/face_scan_tab_navigation.dart';
import '../widgets/face_scan_content.dart';
import 'analysis_results_page.dart';

/// Face scan screen following the Cracker Book design style
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
    return Consumer<FaceScanProvider>(
      builder: (context, provider, child) {
        return LoadingOverlay(
          isVisible: provider.loadingInfo.state.isLoading,
          loadingInfo: provider.loadingInfo,
          isFaceAnalysis: true,
          onCancel: () {
            provider.resetLoadingState();
          },
          onRetry: () {
            // Retry logic will be implemented based on the current operation
            provider.resetLoadingState();
          },
          child: Scaffold(
            backgroundColor: AppColors.backgroundWarm,
            body: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.warmGradient,
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main scrollable content
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Header Section
                          _buildHeader(context),

                          const SizedBox(height: 16),

                          // Main Content Section
                          _buildMainContent(),

                          const SizedBox(height: 20),

                          // Call-to-Action Text
                          _buildCallToActionText(),

                          const SizedBox(height: 20),

                          // Tab Navigation
                          _buildTabNavigation(),

                          const SizedBox(height: 16),

                          // Tab Content
                          _buildTabContent(),

                          // Add bottom padding to avoid footer overlap
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    
                    // Fixed Bottom Navigation
                    FixedBottomNavigation(currentRoute: '/face-scanning'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Top bar with back button and title
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const StandardBackButton(),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgYellow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.face_retouching_natural,
                          size: 18,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Quét khuôn mặt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // User Guide button
                GestureDetector(
                  onTap: () => context.push('/user-guide'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowYellow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 22,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: FaceAnalysisDemo(
        onTap: _handleBeginAnalysis,
      ),
    );
  }

  Widget _buildCallToActionText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: AppColors.borderYellow.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.iconBgYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.primaryDark,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  'Khám phá tính cách của bạn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight.withOpacity(0.6),
                  AppColors.primarySoft,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'thông qua phân tích khuôn mặt!',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon with pastel background
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.cloud_upload_rounded,
                size: 24,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Tải ảnh lên',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chọn một ảnh từ thư viện của bạn để phân tích',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Arrow icon with background
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGuideContent() {
    return GestureDetector(
      onTap: () => context.push('/user-guide'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Row(
              children: [
                // Icon with pastel background
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPeach,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    size: 24,
                    color: AppColors.accent,
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Hướng dẫn sử dụng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hướng dẫn từng bước để quét khuôn mặt',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Arrow icon with background
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPeach,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),

            // Tap to view badge
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.coralGradient,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Nhấn để xem',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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
              SnackBar(
                content: const Text('Không thể khởi tạo camera. Vui lòng thử lại.'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                duration: const Duration(seconds: 3),
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
            SnackBar(
              content: const Text('Ảnh đã được chụp và phân tích thành công!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
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
      final success = await provider.pickImageAndAnalyze(context: context);

      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Ảnh đã được tải lên và phân tích thành công!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );

          // Navigate to results page or show results
          _showAnalysisResults(provider);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Không thể tải lên và phân tích ảnh. Vui lòng thử lại.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 3),
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
            // Không truyền reportImagePath vì đã xóa phần hiển thị báo cáo chi tiết
          ),
        ),
      );
    } else {
      // Fallback to legacy analysis data
      final analysisData = provider.analysisData;
      final annotatedImagePath = provider.annotatedImagePath;

      if (analysisData != null) {
        // Navigate to dedicated results page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AnalysisResultsPage(
              legacyAnalysisData: analysisData,
              annotatedImagePath: annotatedImagePath,
              // Không truyền reportImagePath vì đã xóa phần hiển thị báo cáo chi tiết
            ),
          ),
        );
      } else {
        // Show error dialog if no analysis data
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Lỗi phân tích',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            content: const Text(
              'Không có dữ liệu phân tích. Vui lòng thử lại.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
