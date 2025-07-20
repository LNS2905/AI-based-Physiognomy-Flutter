/// Enum for different loading states in the application
enum LoadingState {
  /// No loading operation in progress
  idle,
  
  /// Initializing camera or services
  initializing,
  
  /// Uploading image to Cloudinary
  uploading,
  
  /// Calling analysis API (face or palm)
  analyzing,
  
  /// Processing API response and preparing results
  processing,
  
  /// Operation completed successfully
  completed,
  
  /// Operation failed with error
  error,
}

/// Extension to provide user-friendly messages for loading states
extension LoadingStateExtension on LoadingState {
  /// Get display message for the loading state
  String get message {
    switch (this) {
      case LoadingState.idle:
        return '';
      case LoadingState.initializing:
        return 'Đang khởi tạo...';
      case LoadingState.uploading:
        return 'Đang tải ảnh lên...';
      case LoadingState.analyzing:
        return 'Đang phân tích...';
      case LoadingState.processing:
        return 'Đang xử lý kết quả...';
      case LoadingState.completed:
        return 'Hoàn thành!';
      case LoadingState.error:
        return 'Đã xảy ra lỗi';
    }
  }

  /// Get specific message for face analysis
  String get faceAnalysisMessage {
    switch (this) {
      case LoadingState.idle:
        return '';
      case LoadingState.initializing:
        return 'Đang khởi tạo camera...';
      case LoadingState.uploading:
        return 'Đang tải ảnh gương mặt lên...';
      case LoadingState.analyzing:
        return 'Đang phân tích gương mặt...';
      case LoadingState.processing:
        return 'Đang xử lý kết quả phân tích...';
      case LoadingState.completed:
        return 'Phân tích gương mặt hoàn thành!';
      case LoadingState.error:
        return 'Lỗi phân tích gương mặt';
    }
  }

  /// Get specific message for palm analysis
  String get palmAnalysisMessage {
    switch (this) {
      case LoadingState.idle:
        return '';
      case LoadingState.initializing:
        return 'Đang khởi tạo camera...';
      case LoadingState.uploading:
        return 'Đang tải ảnh vân tay lên...';
      case LoadingState.analyzing:
        return 'Đang phân tích vân tay...';
      case LoadingState.processing:
        return 'Đang xử lý kết quả phân tích...';
      case LoadingState.completed:
        return 'Phân tích vân tay hoàn thành!';
      case LoadingState.error:
        return 'Lỗi phân tích vân tay';
    }
  }

  /// Check if the state represents an active loading operation
  bool get isLoading {
    return this != LoadingState.idle && 
           this != LoadingState.completed && 
           this != LoadingState.error;
  }

  /// Check if the state represents a successful completion
  bool get isCompleted {
    return this == LoadingState.completed;
  }

  /// Check if the state represents an error
  bool get isError {
    return this == LoadingState.error;
  }

  /// Get progress percentage (0.0 to 1.0) for the loading state
  double get progress {
    switch (this) {
      case LoadingState.idle:
        return 0.0;
      case LoadingState.initializing:
        return 0.1;
      case LoadingState.uploading:
        return 0.3;
      case LoadingState.analyzing:
        return 0.7;
      case LoadingState.processing:
        return 0.9;
      case LoadingState.completed:
        return 1.0;
      case LoadingState.error:
        return 0.0;
    }
  }

  /// Get step number (1-based) for progress indicators
  int get stepNumber {
    switch (this) {
      case LoadingState.idle:
        return 0;
      case LoadingState.initializing:
        return 1;
      case LoadingState.uploading:
        return 2;
      case LoadingState.analyzing:
        return 3;
      case LoadingState.processing:
        return 4;
      case LoadingState.completed:
        return 4;
      case LoadingState.error:
        return 0;
    }
  }

  /// Get total number of steps
  static int get totalSteps => 4;
}

/// Model for detailed loading information
class LoadingInfo {
  final LoadingState state;
  final String? customMessage;
  final double? customProgress;
  final String? errorMessage;
  final bool canRetry;

  const LoadingInfo({
    required this.state,
    this.customMessage,
    this.customProgress,
    this.errorMessage,
    this.canRetry = false,
  });

  /// Get the display message, preferring custom message over default
  String getMessage({bool isFaceAnalysis = true}) {
    if (customMessage != null) return customMessage!;
    
    if (isFaceAnalysis) {
      return state.faceAnalysisMessage;
    } else {
      return state.palmAnalysisMessage;
    }
  }

  /// Get the progress value, preferring custom progress over default
  double getProgress() {
    return customProgress ?? state.progress;
  }

  /// Create a copy with updated values
  LoadingInfo copyWith({
    LoadingState? state,
    String? customMessage,
    double? customProgress,
    String? errorMessage,
    bool? canRetry,
  }) {
    return LoadingInfo(
      state: state ?? this.state,
      customMessage: customMessage ?? this.customMessage,
      customProgress: customProgress ?? this.customProgress,
      errorMessage: errorMessage ?? this.errorMessage,
      canRetry: canRetry ?? this.canRetry,
    );
  }

  /// Create loading info for idle state
  static const LoadingInfo idle = LoadingInfo(state: LoadingState.idle);

  /// Create loading info for error state
  static LoadingInfo error(String message, {bool canRetry = true}) {
    return LoadingInfo(
      state: LoadingState.error,
      errorMessage: message,
      canRetry: canRetry,
    );
  }

  /// Create loading info for completed state
  static const LoadingInfo completed = LoadingInfo(state: LoadingState.completed);
}
