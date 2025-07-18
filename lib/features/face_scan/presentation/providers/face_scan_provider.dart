import 'dart:io';
import '../../../../core/providers/base_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/camera_service.dart';
import '../../../../core/services/image_picker_service.dart';
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
  Future<bool> pickImageAndAnalyze() async {
    try {
      setLoading(true);
      AppLogger.info('Starting image selection from gallery');

      // Pick image from gallery
      final imagePath = await _imagePickerService.pickImageFromGallery();

      if (imagePath == null) {
        AppLogger.info('No image selected from gallery');
        setLoading(false);
        return false;
      }

      AppLogger.info('Image selected: $imagePath');
      setSelectedImagePath(imagePath);

      // Start face analysis using Cloudinary endpoint
      final result = await executeApiOperation(
        () => _repository.analyzeFaceFromCloudinary(imagePath),
        operationName: 'analyzeFaceFromCloudinary',
      );

      if (result != null) {
        // Store Cloudinary analysis result
        _currentCloudinaryResult = result;
        AppLogger.info('Cloudinary face analysis completed successfully');
        return true;
      } else {
        AppLogger.error('Cloudinary face analysis failed');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to pick image and analyze', e);
      return false;
    } finally {
      setLoading(false);
    }
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

  /// Get total harmony score from Cloudinary analysis
  double? get totalHarmonyScore => _currentCloudinaryResult?.analysis?.analysisResult?.face?.proportionality?.overallHarmonyScore;

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
      setLoading(true);
      AppLogger.info('Starting palm image selection from gallery');

      // Pick image from gallery
      final imagePath = await _imagePickerService.pickImageFromGallery();

      if (imagePath == null) {
        AppLogger.info('No image selected from gallery for palm analysis');
        setLoading(false);
        return false;
      }

      AppLogger.info('Palm image selected: $imagePath');
      setSelectedImagePath(imagePath);

      // Start palm analysis using Cloudinary endpoint
      final result = await executeApiOperation(
        () => _repository.analyzePalmFromCloudinary(imagePath),
        operationName: 'analyzePalmFromCloudinary',
      );

      if (result != null) {
        setCurrentPalmResult(result);
        AppLogger.info('Palm analysis completed successfully');
        setLoading(false);
        return true;
      } else {
        AppLogger.error('Palm analysis failed');
        setLoading(false);
        return false;
      }
    } catch (e) {
      AppLogger.error('Exception in pickImageAndAnalyzePalm', e);
      setLoading(false);
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
