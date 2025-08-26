# API Service Documentation

This document describes the API service architecture and how to use it in the Flutter Time Reservation app.

## Architecture Overview

The API layer consists of three main components:

1. **ApiService** - Low-level HTTP client for making API requests
2. **Repositories** - Business logic layer that uses ApiService
3. **Providers** - State management layer that uses Repositories

```
UI Layer (Widgets)
    ↓
State Management (Providers)
    ↓
Business Logic (Repositories)
    ↓
Network Layer (ApiService)
    ↓
Backend API
```

## Files Structure

```
lib/core/
├── services/
│   └── api_service.dart          # HTTP client and API configuration
├── repositories/
│   ├── reservation_repository.dart  # Reservation business logic
│   └── auth_repository.dart         # Authentication business logic
├── models/
│   └── reservation.dart          # Data models with JSON serialization
└── examples/
    └── api_usage_example.dart    # Usage examples and best practices
```

## ApiService

The `ApiService` class handles all HTTP requests to the backend API.

### Features

- **Singleton Pattern** - Single instance throughout the app
- **Authentication** - Automatic token management
- **Error Handling** - Standardized error responses
- **JSON Serialization** - Automatic request/response conversion
- **Type Safety** - Generic response handling

### Configuration

```dart
// Base URL configuration
static const String baseUrl = 'http://localhost:3000';

// Endpoints
static const String recordsEndpoint = '/records';
static const String authEndpoint = '/auth';
```

### Usage

```dart
final apiService = ApiService();

// Set authentication token
apiService.setAuthToken('your-jwt-token');

// Create reservation
final response = await apiService.createReservation(request);
if (response.isSuccess) {
  print('Reservation created: ${response.data}');
} else {
  print('Error: ${response.error}');
}
```

## Repositories

Repositories provide a clean abstraction over the API service and handle business logic.

### ReservationRepository

Manages all reservation-related operations:

- `createReservation()` - Create new reservation
- `getAllReservations()` - Get all reservations
- `getUserReservations()` - Get user's reservations
- `updateReservation()` - Update existing reservation
- `deleteReservation()` - Delete reservation
- `getAvailableTimeSlots()` - Get available time slots
- `getReservationsForDate()` - Get reservations for specific date
- `getReservationStats()` - Get reservation statistics

### AuthRepository

Manages authentication operations:

- `login()` - User login
- `register()` - User registration
- `logout()` - User logout
- `isAuthenticated` - Check authentication status

### Usage Example

```dart
final reservationRepo = ReservationRepository();

try {
  // Create reservation
  final reservation = await reservationRepo.createReservation(
    title: 'Doctor Appointment',
    from: DateTime.now().add(Duration(days: 1)),
    to: DateTime.now().add(Duration(days: 1, hours: 1)),
    description: 'Regular checkup',
  );
  
  print('Created reservation: ${reservation?.id}');
} catch (e) {
  print('Error: $e');
}
```

## Data Models

### Reservation

```dart
class Reservation {
  final String id;
  final DateTime date;
  final String timeSlot;
  final String customerName;
  final String service;
  final ReservationStatus status;
  final DateTime createdAt;
  
  // JSON serialization
  factory Reservation.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### TimeSlot

```dart
class TimeSlot {
  final String id;
  final String displayTime;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  
  // JSON serialization
  factory TimeSlot.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

## Error Handling

### Repository Level

Repositories throw `ReservationException` for business logic errors:

```dart
try {
  final reservations = await repository.getAllReservations();
} catch (e) {
  if (e is ReservationException) {
    print('Business logic error: ${e.message}');
  } else {
    print('Unexpected error: $e');
  }
}
```

### API Level

API responses use `ApiResponse<T>` wrapper:

```dart
final response = await apiService.getAllReservations();
if (response.isSuccess) {
  final reservations = response.data;
} else {
  final error = response.error;
}
```

## Authentication Flow

1. **Login/Register** through `AuthRepository`
2. **Token Storage** handled automatically by `ApiService`
3. **Automatic Headers** added to all authenticated requests
4. **Token Clearing** on logout or 401 errors

```dart
final authRepo = AuthRepository();

// Login
final loginResult = await authRepo.login(
  email: 'user@example.com',
  password: 'password',
);

if (loginResult.isSuccess) {
  // Token is automatically set in ApiService
  print('Logged in: ${loginResult.user?.name}');
} else {
  print('Login failed: ${loginResult.error}');
}
```

## Integration with State Management

Use repositories in your Provider classes:

```dart
class ReservationProvider extends ChangeNotifier {
  final ReservationRepository _repository = ReservationRepository();
  List<Reservation> _reservations = [];
  
  Future<void> loadReservations() async {
    try {
      _reservations = await _repository.getUserReservations();
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
```

## Best Practices

1. **Error Handling** - Always wrap API calls in try-catch blocks
2. **Loading States** - Show loading indicators during API calls
3. **Offline Support** - Implement fallback data when API fails
4. **Validation** - Validate user input before API calls
5. **Caching** - Consider caching responses for better performance
6. **Retry Logic** - Implement retry for failed requests
7. **Logging** - Add proper logging for debugging
8. **Security** - Never log sensitive data like tokens

## Configuration for Different Environments

Update the base URL based on environment:

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );
}
```

Build with environment variables:
```bash
flutter run --dart-define=API_BASE_URL=https://api.yourapp.com
```

## Testing

Mock repositories for unit testing:

```dart
class MockReservationRepository implements ReservationRepository {
  @override
  Future<List<Reservation>> getAllReservations() async {
    return [
      // Mock data
    ];
  }
}
```

## Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  provider: ^6.1.5+1
```

## Backend API Compatibility

This client is compatible with the NestJS backend in this repository:

- **Records API** - `/records` endpoint for reservations
- **Auth API** - `/auth` endpoint for authentication
- **JSON Format** - Standard REST API with JSON payloads

## Troubleshooting

### Common Issues

1. **Network Errors** - Check backend server is running
2. **CORS Issues** - Ensure backend allows Flutter domain
3. **Token Expiry** - Implement token refresh mechanism
4. **Data Format** - Verify JSON structure matches models

### Debug Mode

Enable HTTP logging in debug mode:

```dart
if (kDebugMode) {
  print('API Request: ${request.url}');
  print('API Response: ${response.body}');
}
```

## Future Enhancements

- [ ] Token refresh mechanism
- [ ] Offline data caching
- [ ] Request queuing for offline support
- [ ] Response compression
- [ ] Request/response interceptors
- [ ] GraphQL support
- [ ] WebSocket real-time updates
