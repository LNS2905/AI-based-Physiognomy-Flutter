# AI Physiognomy Flutter App

A modern Flutter application built with Provider + HTTP architecture following 2025 best practices for production-ready mobile development.

## 🏗️ Architecture Overview

This project implements a **Feature-First Architecture** with **Provider for state management** and **HTTP for API calls**, designed for scalability and maintainability.

### Architecture Principles

- **Feature-First Organization**: Code is organized by features rather than layers
- **Provider Pattern**: Simple and effective state management using Provider
- **HTTP Client**: Direct HTTP calls with proper error handling
- **Clean Separation**: Clear separation between data, business logic, and presentation
- **Production Ready**: Comprehensive error handling, logging, and utilities

## 📁 Project Structure

```
lib/
├── core/                          # Core application infrastructure
│   ├── constants/                 # App-wide constants
│   │   └── app_constants.dart
│   ├── errors/                    # Error handling
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── navigation/                # Navigation and routing
│   │   └── app_router.dart
│   ├── network/                   # Network layer
│   │   ├── api_result.dart
│   │   └── http_service.dart
│   ├── providers/                 # Base provider classes
│   │   └── base_provider.dart
│   ├── storage/                   # Data persistence
│   │   └── storage_service.dart
│   ├── theme/                     # App theming
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   └── utils/                     # Utility functions
│       ├── date_utils.dart
│       ├── error_handler.dart
│       ├── logger.dart
│       └── validators.dart
├── features/                      # Feature modules
│   ├── auth/                      # Authentication feature
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       └── providers/
│   └── splash/                    # Splash screen feature
│       └── presentation/
│           └── pages/
└── main.dart                      # App entry point
```

## 🚀 Features

The app is designed to support the following core screens:

- **Splash Screen** - App initialization and loading
- **Intro Screen** - User onboarding (to be implemented)
- **Login Page** - User authentication (to be implemented)
- **Demographic Questions** - User profile setup (to be implemented)
- **Home Page** - Main dashboard (to be implemented)
- **Face Scanning** - AI-powered face analysis (to be implemented)
- **Result** - Analysis results display (to be implemented)
- **Chatbot Page** - AI assistant interaction (to be implemented)
- **Profile Page** - User profile management (to be implemented)

## 🛠️ Technology Stack

### Core Dependencies
- **Flutter SDK**: Latest stable version
- **Provider**: State management
- **HTTP**: API communication
- **GoRouter**: Navigation and routing
- **SharedPreferences**: Local data storage
- **FlutterSecureStorage**: Secure token storage
- **Logger**: Comprehensive logging
- **Equatable**: Value equality
- **Intl**: Internationalization and date formatting

### Development Dependencies
- **BuildRunner**: Code generation
- **JsonAnnotation**: JSON serialization
- **JsonSerializable**: JSON model generation

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

The app uses Provider for state management with a base provider class that includes:
- Loading state management
- Error handling
- Async operation execution
- Automatic disposal

### HTTP Service

Custom HTTP service with:
- Request/response logging
- Automatic error handling
- Timeout configuration
- Token management
- Response parsing

### Error Handling

Comprehensive error handling system:
- Custom exception types
- Failure mapping
- User-friendly error messages
- Global error handling
- Retry mechanisms

### Storage Service

Dual storage approach:
- **Secure Storage**: For sensitive data (tokens, passwords)
- **Shared Preferences**: For app settings and non-sensitive data

### Navigation

Modern navigation using GoRouter:
- Declarative routing
- Type-safe navigation
- Deep linking support
- Navigation logging

## 🎨 Theming

Material Design 3 theming with:
- Light and dark theme support
- Custom color palette
- Consistent typography
- Reusable components

## 🔒 Security

- Secure token storage using FlutterSecureStorage
- Network security with HTTPS
- Input validation
- Error message sanitization

## 📊 Logging

Comprehensive logging system:
- Request/response logging
- State change tracking
- Navigation logging
- Error logging with stack traces

## 🧪 Testing

The architecture supports easy testing with:
- Provider-based state management
- Dependency injection
- Mockable services
- Isolated business logic

## 🚀 Deployment

### Android
- Configure signing keys
- Update app version
- Build release APK/AAB

### iOS
- Configure provisioning profiles
- Update app version
- Build for App Store

## 📈 Performance

Optimizations included:
- Efficient state management
- Image optimization
- Network request optimization
- Memory management

## 🤝 Contributing

1. Follow the established architecture patterns
2. Use the provided base classes
3. Implement proper error handling
4. Add comprehensive logging
5. Write tests for new features

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Check the documentation
- Review the code examples
- Create an issue for bugs
- Follow Flutter best practices

---

**Note**: This is a foundational architecture setup. Individual features and screens need to be implemented based on specific requirements while following the established patterns and conventions.
