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
import '../../data/models/palm_analysis_response_model.dart';
import '../../../face_scan/presentation/providers/face_scan_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../auth/data/models/auth_models.dart';
import '../widgets/palm_analysis_demo.dart';
import '../widgets/palm_scan_tab_navigation.dart';
import '../widgets/palm_scan_content.dart';
import '../widgets/gender_selector_widget.dart';

import 'palm_analysis_results_page.dart';

/// Palm scan screen following the exact design pattern of Face Scan
class PalmScanPage extends StatefulWidget {
  const PalmScanPage({super.key});

  @override
  State<PalmScanPage> createState() => _PalmScanPageState();
}

class _PalmScanPageState extends State<PalmScanPage> {
  Gender? _selectedGender;

  @override
  void initState() {
    super.initState();
    // Set default tab to palm_scan when entering palm scan screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FaceScanProvider>().setSelectedTab('palm_scan');
      // Get default gender from user profile
      final profileProvider = context.read<ProfileProvider>();
      _selectedGender = profileProvider.currentUser?.gender ?? Gender.male;
      setState(() {});
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
                          _buildMainContent(provider),

                          const SizedBox(height: 20),

                          // Gender Selector
                          if (_selectedGender != null)
                            GenderSelectorWidget(
                              selectedGender: _selectedGender!,
                              onGenderChanged: (gender) {
                                setState(() {
                                  _selectedGender = gender;
                                });
                              },
                              helpText: 'Chọn giới tính để xác định tay phân tích (có thể xem cho bạn bè)',
                            ),

                          const SizedBox(height: 16),

                          // AI Disclaimer
                          _buildAIDisclaimer(),

                          const SizedBox(height: 16),

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
                    FixedBottomNavigation(currentRoute: '/palm-scanning'),
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
          Row(
            children: [
              const StandardBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quét đường chỉ tay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Phân tích vân tay bằng AI',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              // User Guide button with pastel background
              GestureDetector(
                onTap: () => context.push('/user-guide'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgYellow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.borderYellow,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowYellow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 22,
                      color: AppColors.primaryDark,
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

  Widget _buildMainContent(FaceScanProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: PalmAnalysisDemo(
        onTap: () => _handleBeginAnalysis(provider),
      ),
    );
  }

  Widget _buildAIDisclaimer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warningLight,
            AppColors.warningLight.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with circle background
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LƯU Ý QUAN TRỌNG',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Phân tích vân tay này được tạo bởi AI và chỉ mang tính giải trí, tham khảo. Kết quả không có cơ sở khoa học và không nên được sử dụng để đưa ra các quyết định quan trọng trong cuộc sống.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPeach,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Nam xem tay trái • Nữ xem tay phải',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.accentDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
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
            // Icon with pastel background
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.cloud_upload_outlined,
                  size: 26,
                  color: AppColors.secondary,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tải ảnh lên',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Chọn một ảnh vân tay từ thư viện để phân tích',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Arrow icon with background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.iconBgTeal,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.secondary,
                ),
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
              blurRadius: 16,
              offset: const Offset(0, 4),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPurple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 26,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hướng dẫn sử dụng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Hướng dẫn từng bước để quét đường chỉ tay',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow icon with background
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.iconBgPurple,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.purple.shade400,
                    ),
                  ),
                ),
              ],
            ),

            // Tap to view badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowYellow,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'Nhấn để xem',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
      AppLogger.info('Selected gender: $_selectedGender');

      // Navigate to camera screen for palm capture with gender parameter
      if (mounted) {
        final result = await context.push<PalmAnalysisResponseModel>(
          '/palm-camera',
          extra: {'gender': _selectedGender},
        );

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
