import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/reservation_provider.dart';
import '../models/reservation.dart';

// Event class for calendar markers
class Event {
  final String title;
  const Event(this.title);
  
  @override
  String toString() => title;
}

class CalendarTable extends StatefulWidget {
  const CalendarTable({super.key});

  @override
  State<CalendarTable> createState() => _CalendarTableState();
}

class _CalendarTableState extends State<CalendarTable> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReservationProvider>().loadReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ReservationProvider, AppProvider>(
      builder: (context, reservationProvider, appProvider, child) {
        return Scaffold(
          appBar: _buildPlatformAppBar(appProvider),
          body: reservationProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    TableCalendar<Event>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        return isSameDay(reservationProvider.selectedDate, day);
                      },
                      calendarFormat: _calendarFormat,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      
                      // Show reserved dates with markers
                      eventLoader: (day) {
                        final reservations = reservationProvider.getReservationsForDate(day);
                        return reservations.map((r) => Event(r.service)).toList();
                      },
                      
                      // Styling
                      calendarStyle: CalendarStyle(
                        // Today's date styling
                        todayDecoration: BoxDecoration(
                          color: appProvider.isDarkMode ? Colors.blue.shade300 : Colors.deepPurple,
                          shape: BoxShape.circle,
                        ),
                        // Selected date styling
                        selectedDecoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        // Weekend styling
                        weekendTextStyle: const TextStyle(
                          color: Colors.red,
                        ),
                        // Outside month dates
                        outsideDaysVisible: false,
                        // Days with events
                        markerDecoration: BoxDecoration(
                          color: appProvider.isDarkMode ? Colors.orange.shade300 : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      // Header styling
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: appProvider.isDarkMode ? Colors.blue.shade600 : Colors.deepPurple,
                          borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                        ),
                        formatButtonTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      
                      // Calendar format options
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                        CalendarFormat.twoWeeks: '2 weeks',
                        CalendarFormat.week: 'Week',
                      },
                      
                      // Event handling
                      onDaySelected: (selectedDay, focusedDay) {
                        reservationProvider.setSelectedDate(selectedDay);
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                        
                        // Show platform-aware feedback
                        _showPlatformSnackBar(
                          context,
                          'Selected: ${selectedDay.toString().split(' ')[0]}',
                        );
                      },
                      
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      
                      onPageChanged: (focusedDay) {
                        setState(() {
                          _focusedDay = focusedDay;
                        });
                      },
                    ),
                    
                    // Show selected date info
                    if (reservationProvider.selectedDate != null)
                      _buildSelectedDateInfo(reservationProvider, appProvider),
                      
                    // Show reservations for selected date
                    if (reservationProvider.selectedDate != null)
                      _buildReservationsList(reservationProvider),
                  ],
                ),
          
          // Floating action button for quick booking
          floatingActionButton: reservationProvider.selectedDate != null
              ? FloatingActionButton.extended(
                  onPressed: () => _showBookingDialog(reservationProvider),
                  icon: const Icon(Icons.add),
                  label: const Text('Quick Book'),
                )
              : null,
        );
      },
    );
  }

  PreferredSizeWidget _buildPlatformAppBar(AppProvider appProvider) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: const Text('Time Reservation'),
        backgroundColor: appProvider.isDarkMode 
            ? CupertinoColors.darkBackgroundGray 
            : CupertinoColors.systemBlue,
      );
    } else {
      return AppBar(
        title: const Text('Time Reservation Calendar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: Platform.isAndroid ? 4 : 0,
        actions: [
          IconButton(
            icon: Icon(appProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: appProvider.toggleDarkMode,
          ),
        ],
      );
    }
  }

  Widget _buildSelectedDateInfo(ReservationProvider reservationProvider, AppProvider appProvider) {
    final selectedDate = reservationProvider.selectedDate!;
    final reservationsCount = reservationProvider.getReservationsForDate(selectedDate).length;
    final availableSlots = reservationProvider.getAvailableTimeSlotsForDate(selectedDate).length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appProvider.isDarkMode ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Selected Date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('$reservationsCount'),
                  const Text('Booked', style: TextStyle(fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Text('$availableSlots'),
                  const Text('Available', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReservationsList(ReservationProvider reservationProvider) {
    final reservations = reservationProvider.getReservationsForDate(
      reservationProvider.selectedDate!
    );
    
    if (reservations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No reservations for this date'),
      );
    }
    
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservations.length,
        itemBuilder: (context, index) {
          final reservation = reservations[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getStatusColor(reservation.status),
                child: Text(reservation.customerName[0]),
              ),
              title: Text(reservation.customerName),
              subtitle: Text('${reservation.timeSlot} - ${reservation.service}'),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => _showCancelDialog(reservationProvider, reservation),
              ),
            ),
          );
        },
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

  void _showBookingDialog(ReservationProvider reservationProvider) {
    final availableSlots = reservationProvider.getAvailableTimeSlotsForDate(
      reservationProvider.selectedDate!
    );
    
    if (availableSlots.isEmpty) {
      _showPlatformSnackBar(context, 'No available time slots for this date');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        selectedDate: reservationProvider.selectedDate!,
        availableSlots: availableSlots,
        onBook: (timeSlot, customerName, service) {
          reservationProvider.addReservation(
            date: reservationProvider.selectedDate!,
            timeSlot: timeSlot,
            customerName: customerName,
            service: service,
          );
        },
      ),
    );
  }

  void _showCancelDialog(ReservationProvider reservationProvider, Reservation reservation) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Cancel Reservation'),
          content: Text('Cancel reservation for ${reservation.customerName}?'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
                reservationProvider.cancelReservation(reservation.id);
              },
              isDestructiveAction: true,
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cancel Reservation'),
          content: Text('Cancel reservation for ${reservation.customerName}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                reservationProvider.cancelReservation(reservation.id);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  void _showPlatformSnackBar(BuildContext context, String message) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}

// Booking Dialog Widget
class BookingDialog extends StatefulWidget {
  final DateTime selectedDate;
  final List<TimeSlot> availableSlots;
  final Function(String timeSlot, String customerName, String service) onBook;

  const BookingDialog({
    Key? key,
    required this.selectedDate,
    required this.availableSlots,
    required this.onBook,
  }) : super(key: key);

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _customerNameController = TextEditingController();
  final _serviceController = TextEditingController();
  String? _selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Book Appointment for ${widget.selectedDate.day}/${widget.selectedDate.month}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _customerNameController,
            decoration: const InputDecoration(
              labelText: 'Customer Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _serviceController,
            decoration: const InputDecoration(
              labelText: 'Service',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTimeSlot,
            decoration: const InputDecoration(
              labelText: 'Time Slot',
              border: OutlineInputBorder(),
            ),
            items: widget.availableSlots.map((slot) {
              return DropdownMenuItem(
                value: slot.displayTime,
                child: Text(slot.displayTime),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedTimeSlot = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canBook() ? () {
            widget.onBook(
              _selectedTimeSlot!,
              _customerNameController.text,
              _serviceController.text,
            );
            Navigator.pop(context);
          } : null,
          child: const Text('Book'),
        ),
      ],
    );
  }

  bool _canBook() {
    return _customerNameController.text.isNotEmpty &&
           _serviceController.text.isNotEmpty &&
           _selectedTimeSlot != null;
  }
}
