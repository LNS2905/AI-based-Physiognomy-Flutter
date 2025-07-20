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
import '../../data/models/palm_analysis_response_model.dart';
import '../../../face_scan/presentation/providers/face_scan_provider.dart';

/// Camera screen for palm capture and analysis
class PalmCameraScreen extends StatefulWidget {
  const PalmCameraScreen({super.key});

  @override
  State<PalmCameraScreen> createState() => _PalmCameraScreenState();
}

class _PalmCameraScreenState extends State<PalmCameraScreen> {
  final CameraService _cameraService = CameraService.instance;
  bool _isCapturing = false;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      // Start camera (this will create the controller)
      await _cameraService.startCamera();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to initialize camera in PalmCameraScreen', e);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cameraService.stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: _buildCameraPreview(),
          ),
          
          // Overlay with instructions
          Positioned.fill(
            child: _buildOverlay(),
          ),
          
          // Top controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildTopControls(),
          ),
          
          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    // Show error if there's an error message
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Lỗi camera',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeCamera,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // Show loading while initializing
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Đang khởi tạo camera...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Check if camera controller is available and initialized
    final controller = _cameraService.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Camera chưa sẵn sàng...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return CameraPreview(controller);
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.3),
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Center(
        child: SizedBox(
          width: 320,
          height: 400,
          child: Stack(
            children: [
              // Palm scanner image overlay
              Center(
                child: Image.asset(
                  'palm-scanner.png',
                  width: 300,
                  height: 380,
                  fit: BoxFit.contain,
                ),
              ),

              // Center guide text
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 120),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🖐️ Đặt bàn tay vào khung',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildTopControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        
        // Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Chụp Ảnh Vân Tay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Placeholder for symmetry
        const SizedBox(width: 50),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Instructions
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Text(
                'Hướng dẫn chụp vân tay:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Đặt bàn tay phẳng trong khung\n• Giữ các ngón tay tách rời\n• Đảm bảo ánh sáng đủ sáng',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Capture button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _isCapturing ? null : _captureAndAnalyzePalm,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _isCapturing ? Colors.grey : AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: _isCapturing
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _captureAndAnalyzePalm() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // 1. Capture image
      final imagePath = await _cameraService.captureImage();
      AppLogger.info('✅ Palm image captured: $imagePath');

      if (!mounted) return;

      // 2. Show loading screen and call API
      final provider = context.read<FaceScanProvider>();

      // Navigate to loading screen
      final result = await Navigator.of(context).push<PalmAnalysisResponseModel>(
        MaterialPageRoute(
          builder: (context) => _PalmCameraAnalysisLoadingScreen(
            imagePath: imagePath,
            provider: provider,
          ),
        ),
      );

      if (!mounted) return;

      // 3. Handle result
      if (result != null) {
        AppLogger.info('✅ Palm analysis success, returning result');
        context.pop(result);
      } else {
        AppLogger.error('❌ Palm analysis failed or was cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phân tích vân tay thất bại hoặc bị hủy'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('❌ Exception in palm capture and analysis', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chụp và phân tích vân tay: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }
}

/// Loading screen for palm camera analysis
class _PalmCameraAnalysisLoadingScreen extends StatefulWidget {
  final String imagePath;
  final FaceScanProvider provider;

  const _PalmCameraAnalysisLoadingScreen({
    required this.imagePath,
    required this.provider,
  });

  @override
  State<_PalmCameraAnalysisLoadingScreen> createState() => _PalmCameraAnalysisLoadingScreenState();
}

class _PalmCameraAnalysisLoadingScreenState extends State<_PalmCameraAnalysisLoadingScreen> {
  @override
  void initState() {
    super.initState();
    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    try {
      final result = await widget.provider.executeMultiStepAnalysis<PalmAnalysisResponseModel>(
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
          final result = await widget.provider.repository.analyzePalmFromCloudinary(widget.imagePath);
          if (result is Success<PalmAnalysisResponseModel>) {
            return result.data;
          } else {
            throw Exception('Palm analysis failed: ${result.failure?.message ?? 'Unknown error'}');
          }
        },
        processStep: (analysisResult) async {
          // Process step
          await Future.delayed(const Duration(milliseconds: 500));
          return analysisResult;
        },
        operationName: 'cameraPalmAnalysis',
        isFaceAnalysis: false,
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
          isFaceAnalysis: false,
          customTitle: 'Phân tích vân tay từ camera',
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
