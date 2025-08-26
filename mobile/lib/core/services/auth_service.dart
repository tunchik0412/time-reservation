import 'api_response.dart';
import 'api_service.dart';

/// Authentication service for handling auth-related API requests
class AuthService extends ApiService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // Authentication Methods

  /// Login user
  Future<ApiResponse<AuthResponse>> login(LoginRequest request) async {
    final result = await post<AuthResponse>(
      '/sign_in',
      (json) => AuthResponse.fromJson(json),
      body: request.toJson(),
    );

    // Set auth token if login successful
    if (result.isSuccess && result.data != null) {
      ApiService.setAuthToken(result.data!.accessToken);
    }

    return result;
  }

  /// Register user
  Future<ApiResponse<AuthResponse>> register(RegisterRequest request) async {
    return post<AuthResponse>(
      '/sign_up',
      (json) => AuthResponse.fromJson(json),
      body: request.toJson(),
    );
  }

  /// Logout user
  Future<ApiResponse<bool>> logout() async {
    final result = await post<bool>(
      '/sign_out',
      (json) => true,
    );

    // Clear auth token regardless of response
    ApiService.clearAuthToken();
    return result;
  }

  /// Refresh authentication token
  Future<ApiResponse<AuthResponse>> refreshToken(String refreshToken) async {
    final result = await post<AuthResponse>(
      '/refresh',
      (json) => AuthResponse.fromJson(json),
      body: {'refreshToken': refreshToken},
    );

    // Update auth token if refresh successful
    if (result.isSuccess && result.data != null) {
      ApiService.setAuthToken(result.data!.accessToken);
    }

    return result;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => ApiService.hasAuthToken;
}

/// Authentication request/response models

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
    };
  }
}

class AuthResponse {
  final String accessToken;
  final String? refreshToken;
  final User? user;

  AuthResponse({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'] as String, // Backend uses snake_case
      refreshToken: json['refresh_token'] as String?, // Optional field
      user: json['user'] != null ? User.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }
}

class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
