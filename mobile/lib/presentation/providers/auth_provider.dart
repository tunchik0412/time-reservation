import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/google_auth_service.dart';
import '../../core/services/apple_auth_service.dart' as apple;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final apple.AppleAuthService _appleAuthService = apple.AppleAuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  AuthProvider() {
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    _isAuthenticated = _authService.isAuthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final loginRequest = LoginRequest(
        email: email.trim(),
        password: password,
      );

      final result = await _authService.login(loginRequest);

      if (result.isSuccess) {
        _currentUser = result.data?.user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Login failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final registerRequest = RegisterRequest(
        name: name.trim(),
        email: email.trim(),
        password: password,
      );

      final result = await _authService.register(registerRequest);

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Registration failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _googleAuthService.signInWithGoogle();

      if (result.isSuccess) {
        _currentUser = result.data?.user;
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Google Sign-In failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Google Sign-In failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> registerWithGoogle() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _googleAuthService.registerWithGoogle();

      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Google registration failed.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Google Sign-Up failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  // Apple Sign-In methods
  Future<bool> signInWithApple() async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _appleAuthService.signInAndAuthenticate();

      if (result.isSuccess && result.data != null) {
        _currentUser = User(
          id: result.data!.user.id.toString(),
          email: result.data!.user.email,
          name: result.data!.user.name,
          createdAt: DateTime.now(),
        );
        
        _isAuthenticated = true;
        _setLoading(false);
        return true;
      } else {
        _setError(result.error ?? 'Apple Sign-In failed. Please try again.');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Apple Sign-In failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> isAppleSignInAvailable() async {
    try {
      return await _appleAuthService.isAppleSignInAvailable();
    } catch (e) {
      return false;
    }
  }

  Future<bool> logout([BuildContext? context]) async {
    _setLoading(true);

    try {
      // Call the auth service logout
      await _authService.logout();
      
      // Sign out from Google if signed in
      await _googleAuthService.signOutFromGoogle();
      
      // Clear local state
      _currentUser = null;
      _isAuthenticated = false;
      
      _setLoading(false);
      
      // Navigate to login page if context is provided
      if (context != null && context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false, // Remove all previous routes
        );
      }
      
      return true;
    } catch (e) {
      _setError('Logout failed. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
