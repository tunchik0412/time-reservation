
/// Model class for a reservation
class Reservation {
  final String id;
  final DateTime date;
  final String timeSlot;
  final String customerName;
  final String service;
  final ReservationStatus status;
  final DateTime createdAt;

  Reservation({
    required this.id,
    required this.date,
    required this.timeSlot,
    required this.customerName,
    required this.service,
    this.status = ReservationStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Reservation copyWith({
    String? id,
    DateTime? date,
    String? timeSlot,
    String? customerName,
    String? service,
    ReservationStatus? status,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      customerName: customerName ?? this.customerName,
      service: service ?? this.service,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Create a Reservation from JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'].toString(),
      date: DateTime.parse(json['from'] as String),
      timeSlot: json['title'] as String,
      customerName: json['customerName'] as String? ?? 'Unknown',
      service: json['description'] as String? ?? 'Service',
      status: _parseStatus(json['status'] as String?),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Convert Reservation to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': timeSlot,
      'from': date.toIso8601String(),
      'to': date.add(Duration(hours: 1)).toIso8601String(), // Assuming 1-hour slots
      'description': service,
      'customerName': customerName,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Parse status string to enum
  static ReservationStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return ReservationStatus.confirmed;
      case 'cancelled':
        return ReservationStatus.cancelled;
      case 'completed':
        return ReservationStatus.completed;
      default:
        return ReservationStatus.pending;
    }
  }

  @override
  String toString() {
    return 'Reservation{id: $id, date: $date, timeSlot: $timeSlot, customerName: $customerName}';
  }
}

/// Reservation status enum
enum ReservationStatus {
  pending,
  confirmed,
  cancelled,
  completed,
}

/// Available time slots
class TimeSlot {
  final String id;
  final String displayTime;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.displayTime,
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
  });

  TimeSlot copyWith({
    String? id,
    String? displayTime,
    DateTime? startTime,
    DateTime? endTime,
    bool? isAvailable,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      displayTime: displayTime ?? this.displayTime,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  /// Create a TimeSlot from JSON
  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'].toString(),
      displayTime: json['displayTime'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  /// Convert TimeSlot to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayTime': displayTime,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
    };
  }
}
