import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/palm_analysis_response_model.dart';
import '../../../face_scan/presentation/providers/face_scan_provider.dart';
import 'palm_analysis_results_page.dart';

/// Palm scan screen following the same pattern as face scan
class PalmScanPage extends StatefulWidget {
  const PalmScanPage({super.key});

  @override
  State<PalmScanPage> createState() => _PalmScanPageState();
}

class _PalmScanPageState extends State<PalmScanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Phân Tích Vân Tay',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Consumer<FaceScanProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                _buildHeaderSection(),
                const SizedBox(height: 24),
                
                // Instructions
                _buildInstructionsSection(),
                const SizedBox(height: 32),
                
                // Action buttons
                _buildActionButtons(provider),
                const SizedBox(height: 24),
                
                // Results section (if available)
                if (provider.currentPalmResult != null)
                  _buildResultsSection(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.secondary.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.back_hand,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          const Text(
            'Phân Tích Vân Tay AI',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Khám phá tính cách và vận mệnh qua đường chỉ tay',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hướng dẫn chụp ảnh vân tay:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildInstructionItem('1. Đặt bàn tay trên nền sáng, phẳng'),
          _buildInstructionItem('2. Đảm bảo ánh sáng đủ và không bị che'),
          _buildInstructionItem('3. Chụp từ trên xuống, bao gồm toàn bộ bàn tay'),
          _buildInstructionItem('4. Giữ tay thẳng và các ngón tay tách rời'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(FaceScanProvider provider) {
    return Column(
      children: [
        // Camera button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: provider.isLoading ? null : () => _handleCameraCapture(provider),
            icon: const Icon(Icons.camera_alt),
            label: const Text(
              'Chụp Ảnh Vân Tay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Gallery button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            onPressed: provider.isLoading ? null : () => _handleGalleryUpload(provider),
            icon: const Icon(Icons.photo_library),
            label: const Text(
              'Tải Ảnh Từ Thư Viện',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        if (provider.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildResultsSection(FaceScanProvider provider) {
    final result = provider.currentPalmResult!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Phân tích hoàn tất',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Phát hiện: ${result.handsDetected} bàn tay',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPalmAnalysisResults(provider),
              child: const Text('Xem Kết Quả Chi Tiết'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCameraCapture(FaceScanProvider provider) async {
    try {
      AppLogger.info('Camera capture button tapped for palm analysis');

      // Navigate to camera screen for palm capture
      // PalmCameraScreen will handle camera initialization itself
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
      AppLogger.error('Error in camera capture for palm analysis', e);
      if (mounted) {
        ErrorHandler.handleError(context, e, customMessage: 'Lỗi khi chụp ảnh vân tay');
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
            comparisonImagePath: palmResult.comparisonImageUrl,
          ),
        ),
      );
    }
  }
}
