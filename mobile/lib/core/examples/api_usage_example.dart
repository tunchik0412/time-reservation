/// Example usage of ApiService and Repositories
/// This file demonstrates how to use the API service and repositories
/// in your Flutter application

import 'package:flutter/material.dart';
import '../repositories/reservation_repository.dart';
import '../repositories/auth_repository.dart';
import '../models/reservation.dart';

/// Example class showing how to use the repositories
class ApiUsageExample {
  final ReservationRepository _reservationRepo = ReservationRepository();
  final AuthRepository _authRepo = AuthRepository();

  /// Example: User authentication flow
  Future<void> authenticateUser() async {
    try {
      // Login user
      final loginResult = await _authRepo.login(
        email: 'user@example.com',
        password: 'password123',
      );

      if (loginResult.isSuccess) {
        print('Login successful!');
        print('User: ${loginResult.user?.name}');
        print('Token: ${loginResult.accessToken}');
      } else {
        print('Login failed: ${loginResult.error}');
      }

      // Register new user
      final registerResult = await _authRepo.register(
        email: 'newuser@example.com',
        password: 'password123',
        name: 'New User',
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

  /// Example: Creating a reservation
  Future<void> createReservation() async {
    try {
      final reservation = await _reservationRepo.createReservation(
        title: 'Doctor Appointment',
        from: DateTime.now().add(const Duration(days: 1, hours: 10)),
        to: DateTime.now().add(const Duration(days: 1, hours: 11)),
        description: 'Regular checkup',
      );

      if (reservation != null) {
        print('Reservation created: ${reservation.id}');
      }
    } catch (e) {
      print('Error creating reservation: $e');
    }
  }

  /// Example: Fetching reservations
  Future<void> fetchReservations() async {
    try {
      // Get all reservations
      final allReservations = await _reservationRepo.getAllReservations();
      print('Total reservations: ${allReservations.length}');

      // Get user's reservations
      final userReservations = await _reservationRepo.getUserReservations();
      print('User reservations: ${userReservations.length}');

      // Get reservations for a specific date
      final today = DateTime.now();
      final todayReservations = await _reservationRepo.getReservationsForDate(today);
      print('Today\'s reservations: ${todayReservations.length}');

    } catch (e) {
      print('Error fetching reservations: $e');
    }
  }

  /// Example: Updating a reservation
  Future<void> updateReservation(String reservationId) async {
    try {
      final updatedReservation = await _reservationRepo.updateReservation(
        id: reservationId,
        title: 'Updated Appointment',
        description: 'Updated description',
      );

      if (updatedReservation != null) {
        print('Reservation updated: ${updatedReservation.id}');
      }
    } catch (e) {
      print('Error updating reservation: $e');
    }
  }

  /// Example: Deleting a reservation
  Future<void> deleteReservation(String reservationId) async {
    try {
      final success = await _reservationRepo.deleteReservation(reservationId);
      if (success) {
        print('Reservation deleted successfully');
      }
    } catch (e) {
      print('Error deleting reservation: $e');
    }
  }

  /// Example: Getting available time slots
  Future<void> getTimeSlots() async {
    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final timeSlots = await _reservationRepo.getAvailableTimeSlots(tomorrow);
      
      print('Available time slots for tomorrow:');
      for (final slot in timeSlots) {
        if (slot.isAvailable) {
          print('- ${slot.displayTime}');
        }
      }
    } catch (e) {
      print('Error getting time slots: $e');
    }
  }

  /// Example: Getting reservation statistics
  Future<void> getStats() async {
    try {
      final stats = await _reservationRepo.getReservationStats();
      
      print('Reservation Statistics:');
      print('Total: ${stats.total}');
      print('Pending: ${stats.pending}');
      print('Confirmed: ${stats.confirmed}');
      print('Completed: ${stats.completed}');
      print('Cancelled: ${stats.cancelled}');
      print('Upcoming: ${stats.upcoming}');
    } catch (e) {
      print('Error getting stats: $e');
    }
  }

  /// Example: Complete reservation flow
  Future<void> completeReservationFlow() async {
    try {
      // 1. Authenticate user
      await authenticateUser();

      // 2. Get available time slots
      await getTimeSlots();

      // 3. Create a reservation
      await createReservation();

      // 4. Fetch reservations
      await fetchReservations();

      // 5. Get statistics
      await getStats();

      // 6. Logout
      await _authRepo.logout();
      print('User logged out');

    } catch (e) {
      print('Error in complete flow: $e');
    }
  }
}

/// Widget example showing how to use repositories in a Flutter widget
class ReservationListWidget extends StatefulWidget {
  const ReservationListWidget({Key? key}) : super(key: key);

  @override
  State<ReservationListWidget> createState() => _ReservationListWidgetState();
}

class _ReservationListWidgetState extends State<ReservationListWidget> {
  final ReservationRepository _repository = ReservationRepository();
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reservations = await _repository.getUserReservations();
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
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
      );
    }

    return ListView.builder(
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return ListTile(
          title: Text(reservation.timeSlot),
          subtitle: Text(reservation.service),
          trailing: Text(reservation.status.name),
          onTap: () => _showReservationDetails(reservation),
        );
      },
    );
  }

  void _showReservationDetails(Reservation reservation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reservation.timeSlot),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customer: ${reservation.customerName}'),
            Text('Service: ${reservation.service}'),
            Text('Date: ${reservation.date}'),
            Text('Status: ${reservation.status.name}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (reservation.status == ReservationStatus.pending)
            ElevatedButton(
              onPressed: () => _cancelReservation(reservation.id),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Future<void> _cancelReservation(String reservationId) async {
    Navigator.pop(context); // Close dialog

    try {
      await _repository.deleteReservation(reservationId);
      _loadReservations(); // Refresh list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling reservation: $e')),
      );
    }
  }
}

/// Usage notes:
/// 
/// 1. Make sure to handle exceptions properly in your UI
/// 2. Use loading states to provide good user experience
/// 3. Implement proper error handling and user feedback
/// 4. Consider using Provider or other state management for repository instances
/// 5. Add proper authentication flow before making API calls
/// 6. Implement offline support and caching as needed
/// 7. Add proper validation for user inputs
/// 8. Consider implementing retry logic for failed API calls
/// 9. Use proper logging for debugging and monitoring
/// 10. Implement proper token refresh mechanism for authentication
