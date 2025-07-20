import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/widgets/analysis_loading_screen.dart';
import '../../../../core/enums/loading_state.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../providers/face_scan_provider.dart';
import 'analysis_results_page.dart';

/// Camera screen for face scanning with beautiful UI design
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService.instance;
  bool _isProcessing = false; // Prevent multiple operations
  bool _isInitializing = true;
  bool _isCapturing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Lock orientation to portrait to prevent orientation tracking
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraService.stopCamera();

    // Restore orientation settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraService.stopCamera();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      await _cameraService.startCamera();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize camera', e);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// SIMPLE: Chụp ảnh và gửi API
  Future<void> _captureImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // 1. Chụp ảnh
      final imagePath = await _cameraService.captureImage();
      AppLogger.info('✅ Image captured: $imagePath');

      if (!mounted) return;

      // 2. Show loading screen and call API
      final provider = context.read<FaceScanProvider>();

      // Navigate to loading screen
      final result = await Navigator.of(context).push<CloudinaryAnalysisResponseModel>(
        MaterialPageRoute(
          builder: (context) => _CameraAnalysisLoadingScreen(
            imagePath: imagePath,
            provider: provider,
          ),
        ),
      );

      if (!mounted) return;

      // 3. Xử lý kết quả
      if (result != null) {
        AppLogger.info('✅ Analysis success, returning result to face-scanning page');
        // Return result to face-scanning page
        context.pop(result);
      } else {
        AppLogger.error('❌ Analysis failed or was cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phân tích thất bại hoặc bị hủy'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('❌ Capture error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
        // Không pop ngay lập tức, để user có thể thấy thông báo lỗi và thử lại
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.switchCamera();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleError(context, e, showSnackBar: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview
            _buildCameraPreview(),

            // Face Scanner Overlay Frame
            _buildFaceScannerOverlay(),

            // Top Controls
            _buildTopControls(),

            // Bottom Controls
            _buildBottomControls(),

            // Loading Overlay
            if (_isInitializing || _isCapturing) _buildLoadingOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_errorMessage != null) {
      return _buildErrorView();
    }

    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      );
    }

    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Text(
          'Camera not available',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize!.height,
          height: controller.value.previewSize!.width,
          child: CameraPreview(controller),
        ),
      ),
    );
  }

  Widget _buildFaceScannerOverlay() {
    return Positioned.fill(
      child: Center(
        child: Container(
          width: 280,
          height: 350,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primary,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(140), // Oval shape for face
          ),
          child: Stack(
            children: [
              // Corner indicators (face scanner style)
              ...List.generate(4, (index) => _buildFaceCornerIndicator(index)),

              // Center guide with face icon
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.face,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Căn chỉnh khuôn mặt',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaceCornerIndicator(int index) {
    const double size = 20;
    const double thickness = 3;

    late Alignment alignment;
    late Widget child;

    switch (index) {
      case 0: // Top-left
        alignment = Alignment.topLeft;
        child = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: thickness),
              left: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 1: // Top-right
        alignment = Alignment.topRight;
        child = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.primary, width: thickness),
              right: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 2: // Bottom-left
        alignment = Alignment.bottomLeft;
        child = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: thickness),
              left: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
      case 3: // Bottom-right
        alignment = Alignment.bottomRight;
        child = Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.primary, width: thickness),
              right: BorderSide(color: AppColors.primary, width: thickness),
            ),
          ),
        );
        break;
    }

    return Align(
      alignment: alignment,
      child: child,
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi camera',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi không xác định',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _isCapturing ? null : () => context.pop(),
              icon: Icon(
                Icons.arrow_back,
                color: _isCapturing ? Colors.grey : Colors.white,
              ),
            ),
          ),
          
          // Title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Face Scan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Switch Camera Button
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: _switchCamera,
              icon: const Icon(
                Icons.flip_camera_ios,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Face Detection Guide
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Đặt khuôn mặt vào trong khung và chụp gương mặt chính diện',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Capture Button
          GestureDetector(
            onTap: _isCapturing ? null : _captureImage,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isCapturing ? Colors.grey : AppColors.primary,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isCapturing ? Icons.hourglass_empty : Icons.camera_alt,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              _isInitializing ? 'Đang khởi tạo camera...' : 'Đang chụp ảnh...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Loading screen for camera analysis
class _CameraAnalysisLoadingScreen extends StatefulWidget {
  final String imagePath;
  final FaceScanProvider provider;

  const _CameraAnalysisLoadingScreen({
    required this.imagePath,
    required this.provider,
  });

  @override
  State<_CameraAnalysisLoadingScreen> createState() => _CameraAnalysisLoadingScreenState();
}

class _CameraAnalysisLoadingScreenState extends State<_CameraAnalysisLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final result = await widget.provider.executeMultiStepAnalysis<CloudinaryAnalysisResponseModel>(
        initializeStep: () async {
          // Initialize step
          await Future.delayed(const Duration(milliseconds: 500));
        },
        uploadStep: () async {
          // Upload step - simulate upload
          await Future.delayed(const Duration(seconds: 1));
        },
        analyzeStep: () async {
          // Analyze step - call actual API
          final result = await widget.provider.repository.analyzeFaceFromCloudinary(widget.imagePath);
          if (result is Success<CloudinaryAnalysisResponseModel>) {
            return result.data;
          } else {
            throw Exception('Analysis failed: ${result.failure?.message ?? 'Unknown error'}');
          }
        },
        processStep: (analysisResult) async {
          // Process step
          await Future.delayed(const Duration(milliseconds: 500));
          return analysisResult;
        },
        operationName: 'cameraFaceAnalysis',
        isFaceAnalysis: true,
      );

      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FaceScanProvider>(
      builder: (context, provider, child) {
        return AnalysisLoadingScreen(
          loadingInfo: provider.loadingInfo,
          isFaceAnalysis: true,
          customTitle: 'Phân tích ảnh từ camera',
          onCancel: () {
            provider.resetLoadingState();
            Navigator.of(context).pop(null);
          },
          onRetry: () {
            provider.resetLoadingState();
            _startAnalysis();
          },
        );
      },
    );
  }
}
