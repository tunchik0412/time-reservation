import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'api_service.dart';
import 'api_response.dart';

// AuthResponse class for Apple authentication
class AuthResponse {
  final String accessToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'user': user.toJson(),
    };
  }
}

// User class for authentication
class User {
  final int id;
  final String email;
  final String name;
  final String? picture;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      name: json['name'] as String,
      picture: json['picture'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
    };
  }
}

class AppleAuthService extends ApiService {
  static final AppleAuthService _instance = AppleAuthService._internal();
  factory AppleAuthService() => _instance;
  AppleAuthService._internal();

  /// Generate a cryptographically secure nonce for Apple Sign-In
  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  /// Generate SHA256 hash of the nonce
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Sign in with Apple ID
  Future<AuthorizationCredentialAppleID?> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      // Request Apple Sign-In
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      print('Apple Sign-In successful');
      print('User ID: ${credential.userIdentifier}');
      print('Email: ${credential.email}');
      print('Given Name: ${credential.givenName}');
      print('Family Name: ${credential.familyName}');

      return credential;
    } catch (e) {
      print('Apple Sign-In error: $e');
      return null;
    }
  }

  /// Send Apple credentials to backend for authentication
  Future<ApiResponse<AuthResponse>> authenticateWithApple(AuthorizationCredentialAppleID credential) async {
    try {
      final requestData = {
        'appleId': credential.userIdentifier,
        'email': credential.email,
        'givenName': credential.givenName,
        'familyName': credential.familyName,
        'identityToken': credential.identityToken,
        'authorizationCode': credential.authorizationCode,
      };

      return await post<AuthResponse>(
        '/apple/token',
        (json) => AuthResponse.fromJson(json),
        body: requestData,
      );
    } catch (e) {
      print('Apple authentication error: $e');
      return ApiResponse<AuthResponse>.error('Apple authentication failed: $e');
    }
  }

  /// Complete Apple Sign-In flow (sign in + authenticate with backend)
  Future<ApiResponse<AuthResponse>> signInAndAuthenticate() async {
    try {
      final credential = await signInWithApple();
      if (credential == null) {
        return ApiResponse<AuthResponse>.error('Apple Sign-In cancelled or failed');
      }

      return await authenticateWithApple(credential);
    } catch (e) {
      print('Apple sign-in and authenticate error: $e');
      return ApiResponse<AuthResponse>.error('Apple sign-in failed: $e');
    }
  }

  /// Check if Apple Sign-In is available
  Future<bool> isAppleSignInAvailable() async {
    try {
      return await SignInWithApple.isAvailable();
    } catch (e) {
      print('Error checking Apple Sign-In availability: $e');
      return false;
    }
  }
}
