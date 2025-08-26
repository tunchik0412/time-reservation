/// Generic API response wrapper used across all API services
class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ApiResponse._(this.data, this.error, this.isSuccess);

  factory ApiResponse.success(T data) {
    return ApiResponse._(data, null, true);
  }

  factory ApiResponse.error(String error) {
    return ApiResponse._(null, error, false);
  }

  /// Check if the response contains data
  bool get hasData => data != null;

  /// Get data or throw an exception if error
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    } else {
      throw ApiException(error ?? 'Unknown error');
    }
  }

  /// Transform the data if successful, otherwise return error response
  ApiResponse<R> map<R>(R Function(T) transform) {
    if (isSuccess && data != null) {
      try {
        return ApiResponse.success(transform(data!));
      } catch (e) {
        return ApiResponse.error('Transform failed: $e');
      }
    } else {
      return ApiResponse.error(error ?? 'No data to transform');
    }
  }

  @override
  String toString() {
    return 'ApiResponse{isSuccess: $isSuccess, data: $data, error: $error}';
  }
}

/// Custom exception for API-related errors
class ApiException implements Exception {
  final String message;
  
  ApiException(this.message);
  
  @override
  String toString() => 'ApiException: $message';
}

/// HTTP status codes for reference
class HttpStatusCodes {
  static const int ok = 200;
  static const int created = 201;
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int internalServerError = 500;
}

/// API configuration constants
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const Duration defaultTimeout = Duration(seconds: 30);
}
