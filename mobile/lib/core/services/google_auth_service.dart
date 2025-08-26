import 'package:google_sign_in/google_sign_in.dart';
import '../services/auth_service.dart';
import '../services/api_response.dart';

/// Enhanced authentication service with Google Sign-In integration
class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  final AuthService _authService = AuthService();

  /// Sign in with Google and authenticate with backend
  Future<ApiResponse<AuthResponse>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return ApiResponse.error('Google Sign-In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // For now, we'll use regular login with Google email
      // In production, you'd implement proper Google token verification on backend
      final loginRequest = LoginRequest(
        email: googleUser.email,
        password: 'google_oauth_${googleAuth.idToken?.substring(0, 20)}',
      );

      return await _authService.login(loginRequest);
      
    } catch (e) {
      return ApiResponse.error('Google Sign-In failed: ${e.toString()}');
    }
  }

  /// Register with Google and create account in backend
  Future<ApiResponse<AuthResponse>> registerWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return ApiResponse.error('Google Sign-In was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a registration request with Google data
      final registerRequest = RegisterRequest(
        email: googleUser.email,
        name: googleUser.displayName ?? 'Google User',
        password: 'google_oauth_${googleAuth.idToken?.substring(0, 20)}',
      );

      return await _authService.register(registerRequest);
      
    } catch (e) {
      return ApiResponse.error('Google registration failed: ${e.toString()}');
    }
  }

  /// Sign out from Google
  Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Handle error silently or log it
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }

  /// Get current Google user
  GoogleSignInAccount? get currentGoogleUser => _googleSignIn.currentUser;
}

/// Request model for Google authentication
class GoogleAuthRequest {
  final String idToken;
  final String accessToken;
  final String email;
  final String name;
  final String? photoUrl;

  GoogleAuthRequest({
    required this.idToken,
    required this.accessToken,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'accessToken': accessToken,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}

/// Request model for Google registration
class GoogleRegisterRequest {
  final String idToken;
  final String accessToken;
  final String email;
  final String name;
  final String? photoUrl;

  GoogleRegisterRequest({
    required this.idToken,
    required this.accessToken,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'idToken': idToken,
      'accessToken': accessToken,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
