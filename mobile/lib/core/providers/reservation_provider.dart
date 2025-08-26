import 'package:flutter/foundation.dart';
import '../models/reservation.dart';

/// Global state provider for reservation management
class ReservationProvider extends ChangeNotifier {
  // Private state
  List<Reservation> _reservations = [];
  DateTime? _selectedDate;
  List<TimeSlot> _availableTimeSlots = [];
  bool _isLoading = false;
  String? _error;

  // Getters (public read-only access)
  List<Reservation> get reservations => List.unmodifiable(_reservations);
  DateTime? get selectedDate => _selectedDate;
  List<TimeSlot> get availableTimeSlots => List.unmodifiable(_availableTimeSlots);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get reservations for a specific date
  List<Reservation> getReservationsForDate(DateTime date) {
    return _reservations.where((reservation) {
      return reservation.date.year == date.year &&
             reservation.date.month == date.month &&
             reservation.date.day == date.day;
    }).toList();
  }

  // Check if a date has any reservations
  bool hasReservationsOnDate(DateTime date) {
    return getReservationsForDate(date).isNotEmpty;
  }

  // Get available time slots for a date
  List<TimeSlot> getAvailableTimeSlotsForDate(DateTime date) {
    final bookedSlots = getReservationsForDate(date).map((r) => r.timeSlot).toSet();
    return _generateTimeSlots(date).where((slot) => 
      !bookedSlots.contains(slot.displayTime)
    ).toList();
  }

  // Actions (state mutations)
  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    if (date != null) {
      _loadAvailableTimeSlots(date);
    }
    notifyListeners();
  }

  Future<void> addReservation({
    required DateTime date,
    required String timeSlot,
    required String customerName,
    required String service,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      final reservation = Reservation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: date,
        timeSlot: timeSlot,
        customerName: customerName,
        service: service,
        status: ReservationStatus.confirmed,
      );

      _reservations.add(reservation);
      
      // Refresh available time slots for the selected date
      if (_selectedDate != null) {
        _loadAvailableTimeSlots(_selectedDate!);
      }
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to create reservation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        _reservations[index] = _reservations[index].copyWith(
          status: ReservationStatus.cancelled
        );
        
        // Refresh available time slots
        if (_selectedDate != null) {
          _loadAvailableTimeSlots(_selectedDate!);
        }
        
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to cancel reservation: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadReservations() async {
    _setLoading(true);
    _clearError();

    try {
      // Simulate API call to load reservations
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data for demonstration
      _reservations = [
        Reservation(
          id: '1',
          date: DateTime.now().add(const Duration(days: 1)),
          timeSlot: '10:00 AM',
          customerName: 'John Doe',
          service: 'Consultation',
          status: ReservationStatus.confirmed,
        ),
        Reservation(
          id: '2',
          date: DateTime.now().add(const Duration(days: 2)),
          timeSlot: '2:00 PM',
          customerName: 'Jane Smith',
          service: 'Treatment',
          status: ReservationStatus.pending,
        ),
      ];
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load reservations: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _loadAvailableTimeSlots(DateTime date) {
    _availableTimeSlots = getAvailableTimeSlotsForDate(date);
  }

  List<TimeSlot> _generateTimeSlots(DateTime date) {
    final slots = <TimeSlot>[];
    final baseDate = DateTime(date.year, date.month, date.day);
    
    // Generate slots from 9 AM to 5 PM
    for (int hour = 9; hour < 17; hour++) {
      final startTime = baseDate.add(Duration(hours: hour));
      final endTime = startTime.add(const Duration(hours: 1));
      
      slots.add(TimeSlot(
        id: '$hour:00',
        displayTime: _formatTime(hour),
        startTime: startTime,
        endTime: endTime,
      ));
    }
    
    return slots;
  }

  String _formatTime(int hour) {
    if (hour == 12) {
      return '12:00 PM';
    } else if (hour > 12) {
      return '${hour - 12}:00 PM';
    } else {
      return '$hour:00 AM';
    }
  }
}

/// Provider for app-wide settings and preferences
class AppProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;

  // Getters
  bool get isDarkMode => _isDarkMode;
  String get selectedLanguage => _selectedLanguage;
  bool get notificationsEnabled => _notificationsEnabled;

  // Actions
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }
}
