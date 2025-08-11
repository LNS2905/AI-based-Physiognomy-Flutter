// New API Test Page
import 'package:flutter/material.dart';
import 'package:ai_physiognomy_app/core/services/new_auth_manager.dart';
import 'package:ai_physiognomy_app/core/services/new_facial_analysis_manager.dart';
import 'package:ai_physiognomy_app/core/services/new_api_service.dart';
import 'package:ai_physiognomy_app/core/utils/logger.dart';
import 'package:ai_physiognomy_app/features/auth/data/models/auth_models.dart';

class NewApiTestPage extends StatefulWidget {
  const NewApiTestPage({super.key});

  @override
  State<NewApiTestPage> createState() => _NewApiTestPageState();
}

class _NewApiTestPageState extends State<NewApiTestPage> {
  final NewAuthManager _authManager = NewAuthManager();
  final NewFacialAnalysisManager _facialManager = NewFacialAnalysisManager();
  final NewApiService _apiService = NewApiService();

  bool _isLoading = false;
  String _status = 'Ready to test new APIs';
  final List<String> _logs = <String>[];

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(0, '${DateTime.now().toLocal()}: $message');
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
    AppLogger.info('NewApiTestPage: $message');
  }

  Future<void> _initializeAuth() async {
    setState(() {
      _isLoading = true;
      _status = 'Initializing authentication...';
    });

    try {
      final isAuthenticated = await _authManager.initialize();
      _addLog('Auth initialization: ${isAuthenticated ? 'Success' : 'Not authenticated'}');
      
      if (isAuthenticated) {
        _addLog('Current user: ${_authManager.userDisplayName}');
        _addLog('User email: ${_authManager.userEmail}');
      }
      
      setState(() {
        _status = isAuthenticated ? 'Authenticated' : 'Not authenticated';
      });
    } catch (e) {
      _addLog('Auth initialization failed: $e');
      setState(() {
        _status = 'Auth initialization failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testApiConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing API connection...';
    });

    try {
      final isConnected = await _apiService.testConnection();
      _addLog('API connection test: ${isConnected ? 'Success' : 'Failed'}');
      
      setState(() {
        _status = isConnected ? 'API connected' : 'API connection failed';
      });
    } catch (e) {
      _addLog('API connection test error: $e');
      setState(() {
        _status = 'API connection test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testRegister() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing register...';
    });

    try {
      // Generate unique email for testing
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final email = 'test$timestamp@example.com';

      final registerResponse = await _authManager.register(
        firstName: 'Test',
        lastName: 'User',
        email: email,
        phone: '1234567890',
        age: 25,
        gender: Gender.male,
        password: 'test123',
        confirmPassword: 'test123',
      );

      _addLog('Register test: Success');
      _addLog('User ID: ${registerResponse.user.id}');
      _addLog('User: ${registerResponse.user.fullName}');
      _addLog('Email: ${registerResponse.user.email}');

      setState(() {
        _status = 'Register successful';
      });
    } catch (e) {
      _addLog('Register test failed: $e');
      setState(() {
        _status = 'Register test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing login...';
    });

    try {
      // Test with the user we just created
      final authResponse = await _authManager.login(
        username: 'test@example.com',
        password: 'test123',
      );

      _addLog('Login test: Success');
      _addLog('Token received: ${authResponse.accessToken.substring(0, 20)}...');
      _addLog('Refresh token: ${authResponse.refreshToken.substring(0, 20)}...');

      setState(() {
        _status = 'Login successful';
      });
    } catch (e) {
      _addLog('Login test failed: $e');
      setState(() {
        _status = 'Login test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Google login...';
    });

    try {
      final authResponse = await _authManager.loginWithGoogle();

      _addLog('Google login test: Success');
      _addLog('Token received: ${authResponse.accessToken.substring(0, 20)}...');
      _addLog('Current user: ${_authManager.userDisplayName}');
      _addLog('User email: ${_authManager.userEmail}');
      
      setState(() {
        _status = 'Google login successful';
      });
    } catch (e) {
      _addLog('Google login test failed: $e');
      setState(() {
        _status = 'Google login test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testGetCurrentUser() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing get current user...';
    });

    try {
      final user = await _authManager.refreshUserData();
      
      _addLog('Get current user test: Success');
      _addLog('User ID: ${user.id}');
      _addLog('Name: ${user.fullName}');
      _addLog('Email: ${user.email}');
      _addLog('Phone: ${user.phone}');
      
      setState(() {
        _status = 'Get current user successful';
      });
    } catch (e) {
      _addLog('Get current user test failed: $e');
      setState(() {
        _status = 'Get current user test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLoadFacialAnalyses() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing load facial analyses...';
    });

    try {
      final analyses = await _facialManager.loadFacialAnalyses();
      
      _addLog('Load facial analyses test: Success');
      _addLog('Found ${analyses.length} analyses');
      
      for (int i = 0; i < analyses.length && i < 3; i++) {
        final analysis = analyses[i];
        _addLog('Analysis ${i + 1}: ${analysis.faceShape}, Score: ${analysis.harmonyScore}');
      }
      
      setState(() {
        _status = 'Load facial analyses successful';
      });
    } catch (e) {
      _addLog('Load facial analyses test failed: $e');
      setState(() {
        _status = 'Load facial analyses test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testCreateMockFacialAnalysis() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing create mock facial analysis...';
    });

    try {
      // Create mock base64 image data
      const mockImageBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==';
      
      final analysis = await _facialManager.processFacialAnalysisFromBase64(mockImageBase64);
      
      _addLog('Create mock facial analysis test: Success');
      _addLog('Analysis ID: ${analysis.id}');
      _addLog('Face shape: ${analysis.faceShape}');
      _addLog('Harmony score: ${analysis.harmonyScore}');
      _addLog('Result: ${analysis.resultText}');
      
      setState(() {
        _status = 'Create mock facial analysis successful';
      });
    } catch (e) {
      _addLog('Create mock facial analysis test failed: $e');
      setState(() {
        _status = 'Create mock facial analysis test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogout() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing logout...';
    });

    try {
      await _authManager.logout();
      
      _addLog('Logout test: Success');
      _addLog('User logged out successfully');
      
      setState(() {
        _status = 'Logout successful';
      });
    } catch (e) {
      _addLog('Logout test failed: $e');
      setState(() {
        _status = 'Logout test failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New API Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _clearLogs,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: _isLoading ? Colors.orange.shade100 : Colors.green.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status: $_status',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                ],
                const SizedBox(height: 8),
                Text(
                  'Auth: ${_authManager.isAuthenticated ? 'Authenticated' : 'Not authenticated'}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (_authManager.isAuthenticated) ...[
                  Text(
                    'User: ${_authManager.userDisplayName}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Email: ${_authManager.userEmail ?? 'N/A'}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
          
          // Test buttons section
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.5,
                children: [
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testApiConnection,
                    child: const Text('Test API Connection'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testRegister,
                    child: const Text('Test Register'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testLogin,
                    child: const Text('Test Login'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGoogleLogin,
                    child: const Text('Test Google Login'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testGetCurrentUser,
                    child: const Text('Get Current User'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testLoadFacialAnalyses,
                    child: const Text('Load Facial Analyses'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testCreateMockFacialAnalysis,
                    child: const Text('Create Mock Analysis'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _initializeAuth,
                    child: const Text('Reinitialize Auth'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _testLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Test Logout'),
                  ),
                ],
              ),
            ),
          ),
          
          // Logs section
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Logs (${_logs.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            _logs[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
