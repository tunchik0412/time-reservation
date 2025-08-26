import '../models/reservation.dart';
import 'api_response.dart';
import 'api_service.dart';

/// Records service for handling reservation-related API requests
class RecordsService extends ApiService {
  static const String recordsEndpoint = '/records';

  // Singleton pattern
  static final RecordsService _instance = RecordsService._internal();
  factory RecordsService() => _instance;
  RecordsService._internal();

  // CRUD Operations for Reservations/Records

  /// Create a new reservation
  Future<ApiResponse<Reservation>> createReservation(CreateReservationRequest request) async {
    return post<Reservation>(
      recordsEndpoint,
      (json) => Reservation.fromJson(json),
      body: request.toJson(),
    );
  }

  /// Get all reservations
  Future<ApiResponse<List<Reservation>>> getAllReservations() async {
    return get<List<Reservation>>(
      recordsEndpoint,
      (json) => (json as List).map((item) => Reservation.fromJson(item)).toList(),
    );
  }

  /// Get user's reservations
  Future<ApiResponse<List<Reservation>>> getUserReservations() async {
    return get<List<Reservation>>(
      '$recordsEndpoint/my',
      (json) => (json as List).map((item) => Reservation.fromJson(item)).toList(),
    );
  }

  /// Get reservation by ID
  Future<ApiResponse<Reservation>> getReservationById(String id) async {
    return get<Reservation>(
      '$recordsEndpoint/$id',
      (json) => Reservation.fromJson(json),
    );
  }

  /// Update a reservation
  Future<ApiResponse<Reservation>> updateReservation(String id, UpdateReservationRequest request) async {
    return patch<Reservation>(
      '$recordsEndpoint/$id',
      (json) => Reservation.fromJson(json),
      body: request.toJson(),
    );
  }

  /// Delete a reservation
  Future<ApiResponse<bool>> deleteReservation(String id) async {
    return deleteSimple('$recordsEndpoint/$id');
  }

  /// Get available time slots for a specific date
  Future<ApiResponse<List<TimeSlot>>> getAvailableTimeSlots(DateTime date) async {
    final dateStr = date.toIso8601String().split('T')[0];
    return get<List<TimeSlot>>(
      '$recordsEndpoint/available-slots',
      (json) => (json as List).map((item) => TimeSlot.fromJson(item)).toList(),
      queryParams: {'date': dateStr},
    );
  }

  /// Get reservations for a specific date range
  Future<ApiResponse<List<Reservation>>> getReservationsByDateRange(DateTime startDate, DateTime endDate) async {
    final startDateStr = startDate.toIso8601String().split('T')[0];
    final endDateStr = endDate.toIso8601String().split('T')[0];
    return get<List<Reservation>>(
      recordsEndpoint,
      (json) => (json as List).map((item) => Reservation.fromJson(item)).toList(),
      queryParams: {
        'startDate': startDateStr,
        'endDate': endDateStr,
      },
    );
  }

  /// Cancel a reservation (soft delete)
  Future<ApiResponse<Reservation>> cancelReservation(String id) async {
    return patch<Reservation>(
      '$recordsEndpoint/$id/cancel',
      (json) => Reservation.fromJson(json),
    );
  }

  /// Confirm a reservation
  Future<ApiResponse<Reservation>> confirmReservation(String id) async {
    return patch<Reservation>(
      '$recordsEndpoint/$id/confirm',
      (json) => Reservation.fromJson(json),
    );
  }
}

/// Request models for reservation API calls

class CreateReservationRequest {
  final String title;
  final DateTime from;
  final DateTime to;
  final String? description;

  CreateReservationRequest({
    required this.title,
    required this.from,
    required this.to,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'description': description ?? '',
    };
  }
}

class UpdateReservationRequest {
  final String? title;
  final DateTime? from;
  final DateTime? to;
  final String? description;

  UpdateReservationRequest({
    this.title,
    this.from,
    this.to,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (title != null) json['title'] = title;
    if (from != null) json['from'] = from!.toIso8601String();
    if (to != null) json['to'] = to!.toIso8601String();
    if (description != null) json['description'] = description;
    return json;
  }
}
