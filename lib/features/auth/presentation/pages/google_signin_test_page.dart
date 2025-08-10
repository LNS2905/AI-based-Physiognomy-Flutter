import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/logout_button.dart';
import '../providers/auth_provider.dart';

/// Test page for Google Sign-In functionality
class GoogleSignInTestPage extends StatefulWidget {
  const GoogleSignInTestPage({super.key});

  @override
  State<GoogleSignInTestPage> createState() => _GoogleSignInTestPageState();
}

class _GoogleSignInTestPageState extends State<GoogleSignInTestPage> {
  String _statusMessage = 'Ready to test Google Sign-In';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In Test'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Current User Info
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current User:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Email: ${authProvider.currentUser?.email ?? 'N/A'}'),
                          Text('Name: ${authProvider.currentUser?.displayName ?? 'N/A'}'),
                          Text('ID: ${authProvider.currentUser?.id ?? 'N/A'}'),
                        ],
                      ),
                    ),
                  );
                }
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No user logged in'),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Test Buttons
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGoogleLogin,
              icon: const Icon(Icons.login),
              label: const Text('Test Google Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testGoogleRegister,
              icon: const Icon(Icons.person_add),
              label: const Text('Test Google Register'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isLoading ? null : _testSilentSignIn,
              icon: const Icon(Icons.refresh),
              label: const Text('Test Silent Sign-In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            const SizedBox(height: 12),

            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isAuthenticated) {
                  return LogoutButton(
                    text: 'Sign Out',
                    icon: Icons.logout,
                    onLogoutStart: () {
                      setState(() {
                        _isLoading = true;
                      });
                    },
                    onLogoutComplete: () {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                    onLogoutError: () {
                      setState(() {
                        _isLoading = false;
                      });
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Google Login...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginWithGoogle(googleToken: 'dummy_token');

      setState(() {
        _statusMessage = success 
            ? 'Google Login successful!' 
            : 'Google Login failed';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Google Login error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleRegister() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Google Register...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.registerWithGoogle();

      setState(() {
        _statusMessage = success 
            ? 'Google Register successful!' 
            : 'Google Register failed';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Google Register error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSilentSignIn() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing Silent Sign-In...';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.silentGoogleSignIn();

      setState(() {
        _statusMessage = success 
            ? 'Silent Sign-In successful!' 
            : 'Silent Sign-In failed (no previous session)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Silent Sign-In error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


}
