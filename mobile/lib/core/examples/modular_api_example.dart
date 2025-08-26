import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/records_service.dart';
import '../models/reservation.dart';

/// Example showing how to use the new modular API services
class ModularApiExample {
  final AuthService _authService = AuthService();
  final RecordsService _recordsService = RecordsService();

  /// Example: Authentication flow
  Future<void> authenticateUser() async {
    try {
      // Login user
      final loginResult = await _authService.login(
        LoginRequest(
          email: 'user@example.com',
          password: 'password123',
        ),
      );

      if (loginResult.isSuccess) {
        print('Login successful!');
        print('User: ${loginResult.data?.user.name}');
        print('Token set automatically in ApiService');
      } else {
        print('Login failed: ${loginResult.error}');
      }

      // Register new user
      final registerResult = await _authService.register(
        RegisterRequest(
          email: 'newuser@example.com',
          password: 'password123',
          name: 'New User',
        ),
      );

      if (registerResult.isSuccess) {
        print('Registration successful!');
      } else {
        print('Registration failed: ${registerResult.error}');
      }

    } catch (e) {
      print('Authentication error: $e');
    }
  }

  /// Example: CRUD operations with Records Service
  Future<void> performCrudOperations() async {
    try {
      // CREATE - New reservation
      final createRequest = CreateReservationRequest(
        title: 'Doctor Appointment',
        from: DateTime.now().add(const Duration(days: 1, hours: 10)),
        to: DateTime.now().add(const Duration(days: 1, hours: 11)),
        description: 'Regular checkup',
      );

      final createResult = await _recordsService.createReservation(createRequest);
      if (createResult.isSuccess) {
        print('Reservation created: ${createResult.data?.id}');
        
        final reservationId = createResult.data!.id;

        // READ - Get reservation
        final getResult = await _recordsService.getReservationById(reservationId);
        if (getResult.isSuccess) {
          print('Retrieved: ${getResult.data?.timeSlot}');
        }

        // UPDATE - Modify reservation
        final updateRequest = UpdateReservationRequest(
          title: 'Updated Appointment',
          description: 'Updated description',
        );

        final updateResult = await _recordsService.updateReservation(reservationId, updateRequest);
        if (updateResult.isSuccess) {
          print('Updated: ${updateResult.data?.timeSlot}');
        }

        // DELETE - Remove reservation
        final deleteResult = await _recordsService.deleteReservation(reservationId);
        if (deleteResult.isSuccess) {
          print('Reservation deleted');
        }
      }
    } catch (e) {
      print('CRUD error: $e');
    }
  }

  /// Example: Advanced operations
  Future<void> advancedOperations() async {
    try {
      // Get all user reservations
      final userReservations = await _recordsService.getUserReservations();
      if (userReservations.isSuccess) {
        print('User has ${userReservations.data?.length} reservations');
      }

      // Get available time slots
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final timeSlots = await _recordsService.getAvailableTimeSlots(tomorrow);
      if (timeSlots.isSuccess) {
        print('Available slots: ${timeSlots.data?.length}');
      }

      // Get reservations by date range
      final startDate = DateTime.now();
      final endDate = DateTime.now().add(const Duration(days: 7));
      final rangeReservations = await _recordsService.getReservationsByDateRange(startDate, endDate);
      if (rangeReservations.isSuccess) {
        print('Reservations in next week: ${rangeReservations.data?.length}');
      }

    } catch (e) {
      print('Advanced operations error: $e');
    }
  }

  /// Example: Check authentication status
  void checkAuthStatus() {
    if (_authService.isAuthenticated) {
      print('User is authenticated');
    } else {
      print('User needs to login');
    }
  }

  /// Example: Complete workflow
  Future<void> completeWorkflow() async {
    print('=== Starting Complete API Workflow ===');
    
    // 1. Authenticate
    await authenticateUser();
    checkAuthStatus();

    // 2. Perform CRUD operations
    await performCrudOperations();

    // 3. Advanced operations
    await advancedOperations();

    // 4. Logout
    final logoutResult = await _authService.logout();
    if (logoutResult.isSuccess) {
      print('Logged out successfully');
    }

    print('=== Workflow Complete ===');
  }
}

/// Flutter Widget example using the new services
class ModularReservationWidget extends StatefulWidget {
  const ModularReservationWidget({Key? key}) : super(key: key);

  @override
  State<ModularReservationWidget> createState() => _ModularReservationWidgetState();
}

class _ModularReservationWidgetState extends State<ModularReservationWidget> {
  final AuthService _authService = AuthService();
  final RecordsService _recordsService = RecordsService();
  
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() {
    setState(() {
      _isAuthenticated = _authService.isAuthenticated;
    });
    
    if (_isAuthenticated) {
      _loadReservations();
    }
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _authService.login(
        LoginRequest(
          email: 'demo@example.com',
          password: 'password',
        ),
      );

      if (result.isSuccess) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
        _loadReservations();
      } else {
        setState(() {
          _error = result.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _recordsService.getUserReservations();
      
      if (result.isSuccess) {
        setState(() {
          _reservations = result.data ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.error;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final result = await _authService.logout();
    if (result.isSuccess) {
      setState(() {
        _isAuthenticated = false;
        _reservations = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login Required')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please login to continue'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Login'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reservations'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $_error'),
                  ElevatedButton(
                    onPressed: _loadReservations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final reservation = _reservations[index];
                return ListTile(
                  title: Text(reservation.timeSlot),
                  subtitle: Text(reservation.service),
                  trailing: Chip(
                    label: Text(reservation.status.name),
                    backgroundColor: _getStatusColor(reservation.status),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadReservations,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
    }
  }
}

/// Architecture Benefits:
/// 
/// 1. **Separation of Concerns**: 
///    - ApiService: Base HTTP logic and token management
///    - AuthService: Authentication-specific operations
///    - RecordsService: Reservation-specific operations
///
/// 2. **Shared Token Management**: 
///    - Token is managed in the base ApiService
///    - Automatically shared across all services
///    - Centralized authentication state
///
/// 3. **Clean Inheritance**: 
///    - Both services extend ApiService
///    - Inherit common HTTP methods (get, post, patch, delete)
///    - Inherit shared response handling
///
/// 4. **Type Safety**: 
///    - Generic response types
///    - Proper error handling
///    - Compile-time safety
///
/// 5. **Maintainability**: 
///    - Easy to add new services
///    - Centralized configuration
///    - Consistent error handling
///
/// 6. **Testability**: 
///    - Services can be mocked independently
///    - Base class can be tested separately
///    - Clear interfaces
