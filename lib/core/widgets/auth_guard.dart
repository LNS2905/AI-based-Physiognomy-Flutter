import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';
import '../../features/auth/presentation/providers/enhanced_auth_provider.dart';

/// Widget that guards routes requiring authentication
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String? redirectRoute;
  final String? loadingMessage;

  const AuthGuard({
    super.key,
    required this.child,
    this.redirectRoute,
    this.loadingMessage,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _hasCheckedAuth = false;
  bool _isListenerAdded = false;
  EnhancedAuthProvider? _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthState();
    });
  }

  void _checkAuthState() {
    if (!_isListenerAdded) {
      _authProvider = context.read<EnhancedAuthProvider>();
      
      // Listen to auth state changes only once
      _authProvider!.addListener(_onAuthStateChanged);
      _isListenerAdded = true;
      
      // Check current state
      _onAuthStateChanged();
    }
  }

  void _onAuthStateChanged() {
    if (!mounted) return;
    
    final authProvider = context.read<EnhancedAuthProvider>();

    AppLogger.info('AuthGuard: Auth state changed - authenticated: ${authProvider.isAuthenticated}, hasInitialized: ${authProvider.hasInitialized}, hasCheckedAuth: $_hasCheckedAuth');

    if (authProvider.hasInitialized) {
      if (authProvider.isAuthenticated) {
        AppLogger.info('AuthGuard: User authenticated, allowing access');
        if (!_hasCheckedAuth) {
          _hasCheckedAuth = true;
          if (mounted) {
            setState(() {});
          }
        }
      } else if (!_hasCheckedAuth) {
        AppLogger.info('AuthGuard: User not authenticated, redirecting');
        _hasCheckedAuth = true;
        final redirectTo = widget.redirectRoute ?? AppConstants.loginRoute;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(redirectTo);
          }
        });
      }
    }
    // If not initialized yet, keep waiting
  }

  @override
  void dispose() {
    if (_isListenerAdded && _authProvider != null) {
      try {
        _authProvider!.removeListener(_onAuthStateChanged);
      } catch (e) {
        AppLogger.error('Error removing auth listener: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't use Consumer since we're already using manual listener
    // This prevents double listening and rebuild loops
    final authProvider = context.read<EnhancedAuthProvider>();
    
    // Show loading while checking auth state
    if (!_hasCheckedAuth || !authProvider.hasInitialized) {
      return _buildLoadingScreen();
    }
    
    // Show content if authenticated
    if (authProvider.isAuthenticated) {
      return widget.child;
    }
    
    // Show loading if auth state is being determined
    return _buildLoadingScreen();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.loadingMessage ?? 'Đang kiểm tra trạng thái đăng nhập...',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension to easily wrap routes with AuthGuard
extension AuthGuardExtension on Widget {
  Widget withAuthGuard({
    String? redirectRoute,
    String? loadingMessage,
  }) {
    return AuthGuard(
      redirectRoute: redirectRoute,
      loadingMessage: loadingMessage,
      child: this,
    );
  }
}
