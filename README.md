# AI Physiognomy Flutter App

A production-ready Flutter mobile application for AI-powered facial and palm analysis using computer vision and machine learning. Built with clean architecture, Provider state management, and comprehensive features including authentication, analysis history, chat assistant, and more.

## 🏗️ Architecture Overview

This project implements a **Feature-First Clean Architecture** with **Provider for state management** and **HTTP for API communication**, designed for scalability, testability, and maintainability.

### Architecture Principles

- **Feature-First Organization**: Code organized by business features rather than technical layers
- **Provider Pattern**: Reactive state management with Provider for predictable state updates
- **Clean Architecture**: Clear separation between data, domain, and presentation layers
- **Repository Pattern**: Abstraction layer between data sources and business logic
- **Dependency Injection**: Loose coupling and easy testing
- **Production Ready**: Comprehensive error handling, logging, and API integration

## 📁 Project Structure

```
lib/
├── core/                              # Core application infrastructure
│   ├── constants/                     # App-wide constants and configurations
│   ├── errors/                        # Custom exceptions and error handling
│   ├── navigation/                    # GoRouter configuration and guards
│   ├── network/                       # HTTP service and API client
│   ├── providers/                     # Base provider classes
│   ├── storage/                       # Secure storage and shared preferences
│   ├── theme/                         # Material Design 3 theming
│   └── utils/                         # Utility functions and helpers
│
├── features/                          # Feature modules
│   ├── splash/                        # App initialization splash screen
│   ├── welcome/                       # Onboarding welcome screens
│   ├── auth/                          # Authentication (Login, Register, Google Sign-In)
│   ├── survey/                        # User demographic questions
│   ├── home/                          # Main dashboard and navigation
│   ├── face_scan/                     # Face scanning with camera integration
│   ├── facial_analysis/               # Face analysis results and interpretation
│   ├── palm_scan/                     # Palm scanning with camera
│   ├── history/                       # Analysis history (facial & palm)
│   ├── profile/                       # User profile and settings
│   ├── ai_conversation/               # Chat assistant with AI
│   ├── news/                          # News feed and articles
│   └── testing/                       # Development testing pages
│
└── main.dart                          # App entry point
```

## ✨ Features

### 🔐 Authentication & Onboarding
- **✅ Google Sign-In Integration**: Firebase authentication with Google OAuth
- **✅ Email/Password Registration**: Secure user registration with validation
- **✅ Login System**: Email/password authentication with remember me
- **✅ Welcome Screens**: Interactive onboarding flow
- **✅ User Survey**: Demographic data collection (age, gender, preferences)

### 📸 AI Analysis
- **✅ Face Scanning**: Real-time camera capture with face detection
- **✅ Face Analysis**: AI-powered facial physiognomy analysis with metrics
- **✅ Palm Scanning**: Camera-based palm image capture with orientation handling
- **✅ Palm Analysis**: Detailed palm reading with interpretations
- **✅ Analysis Results**: Comprehensive results display with charts (Syncfusion)
- **✅ Camera Optimization**: Device-specific fixes for orientation handling

### 📊 History & Statistics
- **✅ Analysis History**: View past facial and palm analyses
- **✅ Detailed Results View**: Revisit complete analysis reports
- **✅ Statistics Dashboard**: User stats including harmony scores and accuracy
- **✅ Pagination Support**: Efficient loading of large history datasets
- **✅ Delete Functionality**: Remove unwanted analysis records

### 👤 Profile Management
- **✅ User Profile**: Display user info, stats, and achievements
- **✅ Password Management**: Change password and reset functionality
- **✅ Profile Statistics**: Analysis count, average scores, member since
- **✅ Avatar Upload**: Profile picture management with image picker
- **✅ Quick Actions**: Easy access to history and settings

### 💬 AI Chat Assistant
- **✅ Chat History**: Conversational AI assistant for questions
- **✅ Message Threading**: View and continue previous conversations
- **✅ Context-Aware Responses**: AI understands physiognomy context

### 📰 News & Content
- **✅ News Feed**: Browse articles related to physiognomy and wellness
- **✅ Article Details**: Read full articles with images
- **✅ Category Filtering**: Filter news by topics

### 🎨 UI/UX Features
- **✅ Material Design 3**: Modern UI with consistent theming
- **✅ Dark Mode Support**: Light and dark theme switching
- **✅ Fixed Bottom Navigation**: Persistent navigation across screens
- **✅ Responsive Design**: Adaptive layouts for different screen sizes
- **✅ Loading States**: Skeleton loaders and progress indicators
- **✅ Error Handling**: User-friendly error messages and retry mechanisms
- **✅ Image Caching**: Efficient image loading with cached_network_image

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter SDK**: Latest stable version (Dart 3.8.1+)
- **Provider**: State management (^6.1.5)
- **HTTP**: RESTful API communication (^1.4.0)
- **GoRouter**: Declarative routing and navigation (^15.2.4)
- **Firebase**: Authentication and Google Sign-In integration (^3.8.0)
- **Camera**: Real-time image capture (^0.11.1) with face_camera (^0.1.4)
- **Image Processing**: image (^4.3.0) for manipulation
- **Cloudinary**: Cloud storage for analysis images (^1.2.0)
- **Syncfusion Charts**: Data visualization for analysis results (^30.1.40)
- **Cached Network Image**: Efficient image loading and caching (^3.4.1)
- **Secure Storage**: FlutterSecureStorage (^9.2.4) for tokens and sensitive data
- **SharedPreferences**: Local app settings storage (^2.5.3)
- **Logger**: Comprehensive logging (^2.6.0)
- **Equatable**: Value equality and immutability (^2.0.7)
- **Intl**: Date formatting and localization (^0.20.2)

### Development Dependencies
- **BuildRunner**: Code generation (^2.5.4)
- **JsonSerializable**: Automatic JSON serialization (^6.9.5)
- **FlutterLints**: Code quality and best practices (^6.0.0)

## 📱 Platform Support

- **Android**: API level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+
- **Permissions**: Camera, Storage, Network access

## 🔧 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / VS Code
- iOS development tools (for iOS builds)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd AI-based-Physiognomy-Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code (if needed)**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏛️ Architecture Details

### State Management with Provider

Provider-based architecture with reactive state updates:
- **BaseProvider**: Abstract class with loading states, error handling, and async execution
- **Feature Providers**: AuthProvider, FacialAnalysisProvider, PalmScanProvider, ProfileProvider, etc.
- **ChangeNotifier**: Efficient UI rebuilds with minimal overhead
- **Automatic disposal**: Memory leak prevention with proper lifecycle management

### API Integration

RESTful API communication with comprehensive features:
- **HTTP Service**: Custom wrapper with logging, error handling, and timeout configuration
- **Token Management**: Automatic JWT token injection and refresh
- **Request Interceptors**: Add authentication headers automatically
- **Response Parsing**: Type-safe JSON deserialization
- **Error Mapping**: Convert HTTP errors to user-friendly messages
- **OpenAPI Specification**: Complete API documentation in swagger.json

### Repository Pattern

Clean data layer abstraction:
- **FacialAnalysisRepository**: Manage face analysis data and API calls
- **PalmAnalysisRepository**: Handle palm analysis operations
- **HistoryRepository**: Fetch and manage analysis history
- **AuthRepository**: Handle authentication and user management
- **Separation of Concerns**: Business logic isolated from data sources

### Camera & Image Processing

Advanced camera handling:
- **Face Camera Integration**: Real-time face detection during capture
- **Palm Scan Camera**: Custom camera configuration for palm scanning
- **Orientation Handling**: Device-specific fixes for camera orientation
- **Image Processing**: Resize, compress, and optimize images before upload
- **Cloudinary Integration**: Upload to cloud storage with transformations

### Storage Service

Dual storage strategy for different data types:
- **Secure Storage**: FlutterSecureStorage for JWT tokens, passwords, and sensitive data
- **Shared Preferences**: App settings, user preferences, and non-sensitive cache
- **Type-Safe Access**: Helper methods for common data types
- **Async Operations**: Non-blocking storage operations

### Navigation & Routing

GoRouter-based navigation system:
- **Declarative Routing**: Define all routes in central configuration
- **Type-Safe Navigation**: Compile-time route validation
- **Auth Guards**: Protect routes based on authentication state
- **Deep Linking**: Support for external links and notifications
- **Navigation Logging**: Track user navigation for analytics

## 🎨 Theming

Material Design 3 implementation:
- **Light & Dark Mode**: Complete theme switching support
- **Custom Color Palette**: Branded colors with Material You guidelines
- **Consistent Typography**: Hierarchy with proper text styles
- **Reusable Widgets**: Component library for consistent UI
- **Responsive Design**: Adaptive layouts for tablets and phones

## 🔒 Security

Production-grade security measures:
- **Secure Token Storage**: JWT tokens stored in FlutterSecureStorage (encrypted)
- **HTTPS Only**: All API calls use secure connections
- **Firebase Auth**: Google Sign-In with OAuth 2.0
- **Input Validation**: Server-side and client-side validation
- **Password Hashing**: Secure password storage (handled by backend)
- **Error Sanitization**: No sensitive data in error messages

## 📊 Logging & Monitoring

Comprehensive logging for debugging and analytics:
- **API Request/Response Logging**: Track all network calls with timestamps
- **State Change Tracking**: Monitor provider state updates
- **Navigation Logging**: Track user flow through the app
- **Error Logging**: Detailed error traces with stack traces
- **Camera Events**: Log camera initialization and capture events
- **Analysis Metrics**: Track analysis success rates and performance

## 📈 Performance Optimizations

- **Image Caching**: Cached network images to reduce bandwidth
- **Lazy Loading**: Load content on-demand with pagination
- **State Optimization**: Efficient Provider updates with notifyListeners
- **Memory Management**: Proper disposal of controllers and resources
- **Image Compression**: Optimize images before upload to reduce size
- **Cloudinary CDN**: Fast image delivery with global CDN

## 🚀 Deployment

### Android
```bash
# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS devices
flutter build ios --release

# Create IPA for App Store
flutter build ipa
```

### Configuration
- Update version in `pubspec.yaml`
- Configure Firebase for each environment
- Set up signing keys (Android) or provisioning profiles (iOS)
- Update API endpoints in constants

## 📚 API Documentation

Complete OpenAPI 3.0 specification available in `swagger.json`:
- **Authentication endpoints**: Login, register, Google Sign-In
- **Face Analysis API**: Upload face image, get analysis results
- **Palm Analysis API**: Upload palm image, get palm reading
- **History endpoints**: Fetch analysis history with pagination
- **Profile management**: Update user info, change password
- **News API**: Fetch articles and news content
- **Chat API**: AI conversation endpoints

## 🔧 Development Setup

### Environment Configuration
Create `.env` file or configure in code:
```dart
API_BASE_URL=https://your-api-endpoint.com
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
```

### Firebase Setup
1. Add `google-services.json` for Android in `android/app/`
2. Add `GoogleService-Info.plist` for iOS in `ios/Runner/`
3. Enable Google Sign-In in Firebase Console

### Build & Run
```bash
# Get dependencies
flutter pub get

# Generate code (JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run

# Run with specific flavor
flutter run --flavor development -t lib/main_development.dart
```

## 🧪 Testing

Testing infrastructure included:
- **Unit Tests**: Test business logic in repositories and services
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows
- **Test Coverage**: Track code coverage with flutter test --coverage

## 🤝 Contributing

Guidelines for contributors:
1. Follow the feature-first architecture pattern
2. Use provided base classes (BaseProvider, etc.)
3. Implement comprehensive error handling
4. Add logging for debugging
5. Write unit tests for new features
6. Update this README for new features

## 📄 License

This project is licensed under the MIT License.

---

**Built with Flutter 💙 | AI-Powered Physiognomy Analysis**
