import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/image_picker_service.dart';
import '../../../../core/network/api_result.dart';
import '../../data/models/face_scan_request_model.dart';
import '../../data/models/face_scan_response_model.dart';
import '../../data/models/cloudinary_analysis_response_model.dart';
import '../../data/repositories/face_scan_repository.dart';
import '../../../palm_scan/data/models/palm_analysis_response_model.dart';

/// Provider for face scanning functionality
class FaceScanProvider extends BaseProvider {
  final FaceScanRepository _repository;

  /// Expose repository for direct access when needed
  FaceScanRepository get repository => _repository;
  final CameraService _cameraService = CameraService.instance;
  final ImagePickerService _imagePickerService = ImagePickerService();

  FaceScanProvider({FaceScanRepository? repository})
      : _repository = repository ?? FaceScanRepository();

  // Current scan state
  FaceScanResponseModel? _currentScan;
  List<FaceScanResponseModel> _scanHistory = [];
  String? _selectedImagePath;
  bool _isCameraActive = false;
  bool _isCameraInitialized = false;
  String _selectedTab = 'face_scan'; // face_scan, upload_photo, user_guide

  // Photo quality retry logic
  int _photoQualityRetryCount = 0;
  static const int _maxPhotoQualityRetries = 3;

  // Palm analysis state
  PalmAnalysisResponseModel? _currentPalmResult;
  List<PalmAnalysisResponseModel> _palmHistory = [];

  // Getters
  FaceScanResponseModel? get currentScan => _currentScan;
  List<FaceScanResponseModel> get scanHistory => _scanHistory;
  String? get selectedImagePath => _selectedImagePath;
  bool get isCameraActive => _isCameraActive;
  bool get isCameraInitialized => _isCameraInitialized;
  String get selectedTab => _selectedTab;
  bool get hasActiveScan => _currentScan != null && _currentScan!.status == 'processing';

  /// Set selected tab
  void setSelectedTab(String tab) {
    if (_selectedTab != tab) {
      _selectedTab = tab;
      AppLogger.logStateChange(runtimeType.toString(), 'setSelectedTab', tab);
      notifyListeners();
    }
  }

  /// Set camera active state
  void setCameraActive(bool active) {
    if (_isCameraActive != active) {
      _isCameraActive = active;
      AppLogger.logStateChange(runtimeType.toString(), 'setCameraActive', active);
      notifyListeners();
    }
  }

  /// Set selected image path
  void setSelectedImagePath(String? path) {
    if (_selectedImagePath != path) {
      _selectedImagePath = path;
      AppLogger.logStateChange(runtimeType.toString(), 'setSelectedImagePath', path);
      notifyListeners();
    }
  }

  /// Set current analysis result (legacy)
  void setCurrentAnalysisResult(Map<String, dynamic> result) {
    _currentAnalysisResult = result;
    AppLogger.logStateChange(runtimeType.toString(), 'setCurrentAnalysisResult', 'Analysis result set');
    notifyListeners();
  }

  /// Set current Cloudinary analysis result
  void setCurrentCloudinaryResult(CloudinaryAnalysisResponseModel result) {
    _currentCloudinaryResult = result;
    AppLogger.logStateChange(runtimeType.toString(), 'setCurrentCloudinaryResult', 'Cloudinary analysis result set');
    notifyListeners();
  }

  /// Set current palm analysis result
  void setCurrentPalmResult(PalmAnalysisResponseModel result) {
    _currentPalmResult = result;
    _palmHistory.add(result);
    AppLogger.logStateChange(runtimeType.toString(), 'setCurrentPalmResult', 'Palm analysis result set');
    notifyListeners();
  }

  // Palm analysis getters
  PalmAnalysisResponseModel? get currentPalmResult => _currentPalmResult;
  List<PalmAnalysisResponseModel> get palmHistory => List.unmodifiable(_palmHistory);

  /// Initialize camera service
  Future<bool> initializeCamera() async {
    try {
      await _cameraService.initialize();
      _isCameraInitialized = true;
      AppLogger.info('Camera service initialized successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _isCameraInitialized = false;
      AppLogger.error('Failed to initialize camera service', e);
      notifyListeners();
      return false;
    }
  }

  /// Check camera permissions (simplified for better compatibility)
  Future<bool> checkCameraPermissions() async {
    try {
      return await _cameraService.hasPermissions();
    } catch (e) {
      AppLogger.error('Failed to check camera permissions', e);
      // Return true to allow camera initialization to proceed
      // The camera plugin will handle permissions automatically
      return true;
    }
  }

  /// Request camera permissions (simplified for better compatibility)
  Future<bool> requestCameraPermissions() async {
    try {
      return await _cameraService.requestPermissions();
    } catch (e) {
      AppLogger.error('Failed to request camera permissions', e);
      // Return true to allow camera initialization to proceed
      // The camera plugin will handle permissions automatically
      return true;
    }
  }

  /// Start face analysis from camera
  Future<bool> startFaceAnalysisFromCamera(String imagePath) async {
    final request = FaceScanRequestModel(
      imagePath: imagePath,
      analysisTypes: ['facial_features', 'personality_traits'],
      metadata: {
        'source': 'camera',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    final result = await executeApiOperation(
      () => _repository.startFaceAnalysis(request),
      operationName: 'startFaceAnalysisFromCamera',
    );

    if (result != null) {
      _currentScan = result;
      setSelectedImagePath(imagePath);
      AppLogger.info('Face analysis started from camera: ${result.id}');
      return true;
    }
    return false;
  }

  /// Start face analysis from uploaded image
  Future<bool> startFaceAnalysisFromUpload(String imagePath) async {
    // First upload the image
    final uploadResult = await executeApiOperation(
      () => _repository.uploadImage(imagePath),
      operationName: 'uploadImage',
    );

    if (uploadResult == null) {
      return false;
    }

    // Then start analysis
    final request = FaceScanRequestModel(
      imagePath: imagePath,
      analysisTypes: ['facial_features', 'personality_traits'],
      metadata: {
        'source': 'upload',
        'timestamp': DateTime.now().toIso8601String(),
        'upload_id': uploadResult['upload_id'],
      },
    );

    final result = await executeApiOperation(
      () => _repository.startFaceAnalysis(request),
      operationName: 'startFaceAnalysisFromUpload',
    );

    if (result != null) {
      _currentScan = result;
      setSelectedImagePath(imagePath);
      AppLogger.info('Face analysis started from upload: ${result.id}');
      return true;
    }
    return false;
  }

  /// Check analysis status
  Future<void> checkAnalysisStatus() async {
    if (_currentScan == null) return;

    final result = await executeApiOperation(
      () => _repository.getFaceAnalysisStatus(_currentScan!.id),
      operationName: 'checkAnalysisStatus',
      showLoading: false,
    );

    if (result != null) {
      _currentScan = result;
      AppLogger.info('Analysis status updated: ${result.status}');
      
      // If analysis is complete, add to history
      if (result.status == 'completed' && result.analysis != null) {
        _addToHistory(result);
      }
    }
  }

  /// Load scan history
  Future<void> loadScanHistory() async {
    final result = await executeApiOperation(
      () => _repository.getFaceAnalysisHistory(),
      operationName: 'loadScanHistory',
    );

    if (result != null) {
      _scanHistory = result;
      AppLogger.info('Scan history loaded: ${result.length} items');
    }
  }

  /// Delete scan from history
  Future<bool> deleteScan(String scanId) async {
    final result = await executeApiOperation(
      () => _repository.deleteFaceAnalysis(scanId),
      operationName: 'deleteScan',
    );

    if (result == true) {
      _scanHistory.removeWhere((scan) => scan.id == scanId);
      if (_currentScan?.id == scanId) {
        _currentScan = null;
      }
      AppLogger.info('Scan deleted: $scanId');
      return true;
    }
    return false;
  }

  /// Clear current scan
  void clearCurrentScan() {
    _currentScan = null;
    _selectedImagePath = null;
    AppLogger.logStateChange(runtimeType.toString(), 'clearCurrentScan', null);
    notifyListeners();
  }

  /// Add scan to history
  void _addToHistory(FaceScanResponseModel scan) {
    final existingIndex = _scanHistory.indexWhere((s) => s.id == scan.id);
    if (existingIndex >= 0) {
      _scanHistory[existingIndex] = scan;
    } else {
      _scanHistory.insert(0, scan);
    }
    notifyListeners();
  }

  /// Get scan by ID
  FaceScanResponseModel? getScanById(String id) {
    try {
      return _scanHistory.firstWhere((scan) => scan.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if image file exists and is valid
  bool isValidImageFile(String? path) {
    if (path == null || path.isEmpty) return false;

    final file = File(path);
    if (!file.existsSync()) return false;

    final extension = path.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'bmp', 'webp'].contains(extension);
  }

  /// Pick image from gallery and start analysis
  Future<bool> pickImageAndAnalyze({BuildContext? context}) async {
    try {
      AppLogger.info('Starting image selection from gallery');

      final result = await executeMultiStepAnalysis<CloudinaryAnalysisResponseModel>(
        initializeStep: () async {
          // Initialize step - prepare for image selection
          await Future.delayed(const Duration(milliseconds: 500));
        },
        uploadStep: () async {
          // Pick image from gallery
          final imagePath = await _imagePickerService.pickImageFromGallery();

          if (imagePath == null) {
            AppLogger.info('No image selected from gallery');
            throw Exception('Không có ảnh nào được chọn');
          }

          AppLogger.info('Image selected: $imagePath');
          setSelectedImagePath(imagePath);
        },
        analyzeStep: () async {
          // Start face analysis using Cloudinary endpoint
          final result = await _repository.analyzeFaceFromCloudinary(_selectedImagePath!);
          if (result is Success<CloudinaryAnalysisResponseModel>) {
            return result.data;
          } else {
            // Check if it's a validation error (photo quality or face detection)
            if (result.failure?.code == 'PHOTO_QUALITY_LOW' || result.failure?.code == 'FACE_DETECTION_FAILED') {
              throw ValidationException(
                message: result.failure!.message,
                code: result.failure!.code,
              );
            }
            throw Exception('Face analysis failed: ${result.failure?.message ?? 'Unknown error'}');
          }
        },
        processStep: (analysisResult) async {
          // Process and store the result
          _currentCloudinaryResult = analysisResult;
          AppLogger.info('Cloudinary face analysis completed successfully');
          return analysisResult;
        },
        operationName: 'pickImageAndAnalyzeFace',
        isFaceAnalysis: true,
      );

      return result != null;
    } on ValidationException catch (e) {
      AppLogger.error('ValidationException caught: $e');
      AppLogger.info('🔍 ValidationException details:');
      AppLogger.info('  - message: ${e.message}');
      AppLogger.info('  - code: ${e.code}');

      if (context != null) {
        if (e.code == 'PHOTO_QUALITY_LOW') {
          AppLogger.info('🔄 Handling photo quality error with retry logic');
          return await _handlePhotoQualityError(context);
        } else if (e.code == 'FACE_DETECTION_FAILED') {
          AppLogger.info('🔄 Handling face detection error with retry logic');
          return await _handleFaceDetectionError(context);
        }
      }

      return false;
    } catch (e) {
      AppLogger.error('Failed to pick image and analyze', e);
      AppLogger.info('🔍 Exception type: ${e.runtimeType}');

      // Check if the exception message contains validation error info
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('ảnh chụp chưa chuẩn') && context != null) {
        AppLogger.info('🔄 Detected photo quality error from exception message');
        return await _handlePhotoQualityError(context);
      } else if (errorMessage.contains('chụp ảnh chưa chính xác') && context != null) {
        AppLogger.info('🔄 Detected face detection error from exception message');
        return await _handleFaceDetectionError(context);
      }

      return false;
    }
  }

  /// Handle photo quality error with retry logic
  Future<bool> _handlePhotoQualityError(BuildContext context) async {
    _photoQualityRetryCount++;

    // Show error dialog with guidance
    final shouldRetry = await ErrorHandler.showPhotoQualityErrorDialog(
      context,
      retryCount: _photoQualityRetryCount,
      maxRetries: _maxPhotoQualityRetries,
    );

    if (shouldRetry && _photoQualityRetryCount <= _maxPhotoQualityRetries) {
      // Reset selected image and try again
      _selectedImagePath = null;
      notifyListeners();
      return await pickImageAndAnalyze(context: context);
    } else {
      // Reset retry counter for next attempt
      _photoQualityRetryCount = 0;
      return false;
    }
  }

  /// Handle face detection error with retry logic
  Future<bool> _handleFaceDetectionError(BuildContext context) async {
    _photoQualityRetryCount++;

    // Show error dialog with face detection guidance
    final shouldRetry = await ErrorHandler.showFaceDetectionErrorDialog(
      context,
      retryCount: _photoQualityRetryCount,
      maxRetries: _maxPhotoQualityRetries,
    );

    if (shouldRetry && _photoQualityRetryCount <= _maxPhotoQualityRetries) {
      // Reset selected image and try again
      _selectedImagePath = null;
      notifyListeners();
      return await pickImageAndAnalyze(context: context);
    } else {
      // Reset retry counter for next attempt
      _photoQualityRetryCount = 0;
      return false;
    }
  }

  /// Reset photo quality retry counter
  void resetPhotoQualityRetryCounter() {
    _photoQualityRetryCount = 0;
  }

  /// Reset all error states and retry counters
  void resetErrorState() {
    _photoQualityRetryCount = 0;
    resetLoadingState();
    notifyListeners();
  }

  // Store analysis results
  Map<String, dynamic>? _currentAnalysisResult;
  CloudinaryAnalysisResponseModel? _currentCloudinaryResult;

  /// Get current analysis result (legacy)
  Map<String, dynamic>? get currentAnalysisResult => _currentAnalysisResult;

  /// Get current Cloudinary analysis result
  CloudinaryAnalysisResponseModel? get currentCloudinaryResult => _currentCloudinaryResult;

  /// Get annotated image URL from Cloudinary analysis
  String? get annotatedImageUrl => _currentCloudinaryResult?.annotatedImageUrl;

  /// Get report image URL from Cloudinary analysis (using annotated image URL)
  String? get reportImageUrl => _currentCloudinaryResult?.annotatedImageUrl;



  /// Get analysis data from Cloudinary analysis
  CloudinaryAnalysisDataModel? get cloudinaryAnalysisData => _currentCloudinaryResult?.analysis;

  /// Get face shape from analysis
  String? get faceShape => _currentCloudinaryResult?.analysis?.analysisResult?.face?.shape?.primary;

  /// Get physiognomy result text
  String? get physiognomyResult => _currentCloudinaryResult?.analysis?.result;

  /// Get legacy annotated image path (for backward compatibility)
  String? get annotatedImagePath => _currentAnalysisResult?['annotated_image_path'];

  /// Get legacy report image path (for backward compatibility)
  String? get reportImagePath => _currentAnalysisResult?['report_image_path'];

  /// Get legacy analysis data (for backward compatibility)
  Map<String, dynamic>? get analysisData => _currentAnalysisResult?['analysis_data'];

  /// Clear current analysis result
  void clearAnalysisResult() {
    _currentAnalysisResult = null;
    notifyListeners();
  }

  /// Pick image from gallery and analyze palm
  Future<bool> pickImageAndAnalyzePalm() async {
    try {
      AppLogger.info('Starting palm image selection from gallery');

      final result = await executeMultiStepAnalysis<PalmAnalysisResponseModel>(
        initializeStep: () async {
          // Initialize step - prepare for image selection
          await Future.delayed(const Duration(milliseconds: 500));
        },
        uploadStep: () async {
          // Pick image from gallery
          final imagePath = await _imagePickerService.pickImageFromGallery();

          if (imagePath == null) {
            AppLogger.info('No image selected from gallery for palm analysis');
            throw Exception('Không có ảnh nào được chọn');
          }

          AppLogger.info('Palm image selected: $imagePath');
          setSelectedImagePath(imagePath);
        },
        analyzeStep: () async {
          // Start palm analysis using Cloudinary endpoint
          final result = await _repository.analyzePalmFromCloudinary(_selectedImagePath!);
          if (result is Success<PalmAnalysisResponseModel>) {
            return result.data;
          } else {
            throw Exception('Palm analysis failed: ${result.failure?.message ?? 'Unknown error'}');
          }
        },
        processStep: (analysisResult) async {
          // Process and store the result
          setCurrentPalmResult(analysisResult);
          AppLogger.info('Palm analysis completed successfully');
          return analysisResult;
        },
        operationName: 'pickImageAndAnalyzePalm',
        isFaceAnalysis: false,
      );

      return result != null;
    } catch (e) {
      AppLogger.error('Exception in pickImageAndAnalyzePalm', e);
      return false;
    }
  }

  @override
  void dispose() {
    _currentScan = null;
    _scanHistory.clear();
    _selectedImagePath = null;
    _isCameraActive = false;
    _currentPalmResult = null;
    _palmHistory.clear();
    super.dispose();
  }
}
