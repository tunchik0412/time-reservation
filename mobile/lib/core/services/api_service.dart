import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_response.dart';
import '../config/app_config.dart';

/// Base API Service class that encapsulates common HTTP logic
/// and access token management
abstract class ApiService {
  // Get base URL from configuration
  static String get baseUrl => AppConfig.apiBaseUrl;
  
  // Headers for API requests
  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Shared authentication token across all services
  static String? _authToken;

  /// Get headers with authentication token if available
  Map<String, String> get headers {
    final headers = Map<String, String>.from(_headers);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Set authentication token (shared across all services)
  static void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token (shared across all services)
  static void clearAuthToken() {
    _authToken = null;
  }

  /// Check if user has authentication token
  static bool get hasAuthToken => _authToken != null;

  /// Get current auth token
  static String? get authToken => _authToken;

  /// Generic method to handle HTTP responses
  ApiResponse<T> handleResponse<T>(
    http.Response response,
    T Function(dynamic) fromJson,
  ) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          final data = jsonDecode(response.body);
          return ApiResponse.success(fromJson(data));
        } catch (e) {
          return ApiResponse.error('Failed to parse response: $e');
        }
      case 400:
        return ApiResponse.error('Bad request: ${response.body}');
      case 401:
        clearAuthToken();
        return ApiResponse.error('Unauthorized: Please login again');
      case 403:
        return ApiResponse.error('Forbidden: Access denied');
      case 404:
        return ApiResponse.error('Not found: ${response.body}');
      case 500:
        return ApiResponse.error('Server error: Please try again later');
      default:
        return ApiResponse.error('Unknown error: ${response.statusCode}');
    }
  }

  /// Generic GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http.get(uri, headers: headers);
      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      return handleResponse<T>(response, fromJson);
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Simple DELETE request that returns boolean
  Future<ApiResponse<bool>> deleteSimple(String endpoint) async {
    return delete<bool>(endpoint, (json) => true);
  }
}
