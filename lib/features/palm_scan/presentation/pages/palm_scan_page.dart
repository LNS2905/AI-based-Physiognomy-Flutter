import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/enums/loading_state.dart';
import '../../data/models/palm_analysis_response_model.dart';
import '../../../face_scan/presentation/providers/face_scan_provider.dart';
import '../widgets/palm_analysis_demo.dart';
import '../widgets/palm_scan_tab_navigation.dart';
import '../widgets/palm_scan_content.dart';

import 'palm_analysis_results_page.dart';

/// Palm scan screen following the exact design pattern of Face Scan
class PalmScanPage extends StatefulWidget {
  const PalmScanPage({super.key});

  @override
  State<PalmScanPage> createState() => _PalmScanPageState();
}

class _PalmScanPageState extends State<PalmScanPage> {
  @override
  void initState() {
    super.initState();
    // Set default tab to palm_scan when entering palm scan screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceScanProvider>().setSelectedTab('palm_scan');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FaceScanProvider>(
      builder: (context, provider, child) {
        return LoadingOverlay(
          isVisible: provider.loadingInfo.state.isLoading,
          loadingInfo: provider.loadingInfo,
          isFaceAnalysis: false, // This is palm analysis
          onCancel: () {
            provider.resetLoadingState();
          },
          onRetry: () {
            // Retry logic will be implemented based on the current operation
            provider.resetLoadingState();
          },
          child: Scaffold(
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
                child: Stack(
                  children: [
                    // Main scrollable content
                    SingleChildScrollView(
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

                          // Add bottom padding to avoid footer overlap
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                    
                    // Fixed Bottom Navigation
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildBottomNavigation(),
                      ),
                    ),
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
                    'Quét vân tay',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // History button
                GestureDetector(
                  onTap: () => context.push('/palm-analysis-history'),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.history,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
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
              'QUÉT VÂN TAY',
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
            'PHÂN TÍCH CHỈ TAY AI',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 40),
          const PalmAnalysisDemo(),
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
                  'Khám phá vận mệnh của bạn',
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
            'thông qua phân tích đường chỉ tay!',
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
          return PalmScanTabNavigation(
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
            case 'palm_scan':
              return PalmScanContent(
                onBeginAnalysis: () => _handleBeginAnalysis(provider),
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
                      'Chọn một ảnh vân tay từ thư viện để phân tích',
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
                          'Hướng dẫn từng bước để quét vân tay',
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
          _buildBottomNavItem(
            Icons.home_outlined,
            isActive: false,
            onTap: () => _navigateToHome(),
          ),
          _buildBottomNavItem(
            Icons.search_outlined,
            isActive: false,
            onTap: () => _navigateToSearch(),
          ),
          _buildBottomNavItem(
            Icons.back_hand,
            isActive: true,
            onTap: () => {}, // Current page, no action needed
          ),
          _buildBottomNavItem(
            Icons.person_outline,
            isActive: false,
            onTap: () => _navigateToProfile(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, {required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }

  // Navigation methods
  void _navigateToHome() {
    context.go('/home');
  }

  void _navigateToSearch() {
    // Navigate to search/history page
    context.push('/history');
  }

  void _navigateToProfile() {
    context.push('/profile');
  }

  /// Handle upload photo button tap
  Future<void> _handleUploadPhoto() async {
    final provider = context.read<FaceScanProvider>();

    try {
      AppLogger.info('Upload palm photo button tapped');

      // Pick image and analyze palm
      final success = await provider.pickImageAndAnalyzePalm();

      if (mounted) {
        if (success) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh vân tay đã được tải lên và phân tích thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          // Navigate to results page or show results
          _showPalmAnalysisResults(provider);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tải lên và phân tích ảnh vân tay. Vui lòng thử lại.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to handle upload palm photo', e);
      if (mounted) {
        ErrorHandler.handleError(context, e, showSnackBar: true);
      }
    }
  }

  Future<void> _handleBeginAnalysis(FaceScanProvider provider) async {
    try {
      AppLogger.info('Begin palm analysis button tapped');

      // Navigate to camera screen for palm capture
      if (mounted) {
        final result = await context.push<PalmAnalysisResponseModel>('/palm-camera');

        if (result != null && mounted) {
          provider.setCurrentPalmResult(result);
          provider.setSelectedImagePath('');

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh vân tay đã được chụp và phân tích thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          _showPalmAnalysisResults(provider);
        }
      }
    } catch (e) {
      AppLogger.error('Error in palm analysis', e);
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Lỗi khi phân tích vân tay');
      }
    }
  }

  Future<void> _handleGalleryUpload(FaceScanProvider provider) async {
    try {
      AppLogger.info('Upload palm photo button tapped');

      final success = await provider.pickImageAndAnalyzePalm();

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ảnh vân tay đã được tải lên và phân tích thành công!'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );

          _showPalmAnalysisResults(provider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tải lên và phân tích ảnh vân tay. Vui lòng thử lại.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Error in gallery upload for palm analysis', e);
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Lỗi khi tải ảnh vân tay');
      }
    }
  }

  void _showPalmAnalysisResults(FaceScanProvider provider) {
    final palmResult = provider.currentPalmResult;

    if (palmResult != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PalmAnalysisResultsPage(
            palmResult: palmResult,
            annotatedImagePath: palmResult.annotatedImageUrl,
          ),
        ),
      );
    }
  }
}
