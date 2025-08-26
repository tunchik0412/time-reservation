import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/reservation_provider.dart';
import '../../../core/models/reservation.dart';

class PersonalPage extends StatelessWidget {
  const PersonalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, reservationProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'john.doe@example.com',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '+1 (555) 123-4567',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Edit profile
                          },
                          icon: const Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Stats Section
                Text(
                  'Your Statistics',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Total Bookings',
                        '${reservationProvider.reservations.length}',
                        Icons.calendar_month,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'This Month',
                        '${_getThisMonthReservations(reservationProvider)}',
                        Icons.calendar_today,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Completed',
                        '${_getCompletedReservations(reservationProvider)}',
                        Icons.check_circle,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'Upcoming',
                        '${_getUpcomingReservations(reservationProvider)}',
                        Icons.schedule,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Recent Activity Section
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                
                Expanded(
                  child: _buildRecentActivity(reservationProvider),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(ReservationProvider provider) {
    final recentReservations = provider.reservations
        .where((r) => r.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (recentReservations.isEmpty) {
      return const Center(
        child: Text('No recent activity'),
      );
    }

    return ListView.builder(
      itemCount: recentReservations.length,
      itemBuilder: (context, index) {
        final reservation = recentReservations[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(reservation.status),
              child: Icon(
                _getStatusIcon(reservation.status),
                color: Colors.white,
              ),
            ),
            title: Text(reservation.service),
            subtitle: Text(
              '${reservation.date.day}/${reservation.date.month}/${reservation.date.year} at ${reservation.timeSlot}',
            ),
            trailing: Text(
              _getStatusText(reservation.status),
              style: TextStyle(
                color: _getStatusColor(reservation.status),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  int _getThisMonthReservations(ReservationProvider provider) {
    final now = DateTime.now();
    return provider.reservations
        .where((r) => r.date.year == now.year && r.date.month == now.month)
        .length;
  }

  int _getCompletedReservations(ReservationProvider provider) {
    return provider.reservations
        .where((r) => r.status == ReservationStatus.completed)
        .length;
  }

  int _getUpcomingReservations(ReservationProvider provider) {
    final now = DateTime.now();
    return provider.reservations
        .where((r) => r.date.isAfter(now) && r.status == ReservationStatus.confirmed)
        .length;
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

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Icons.check;
      case ReservationStatus.pending:
        return Icons.schedule;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      case ReservationStatus.completed:
        return Icons.check_circle;
    }
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return 'Confirmed';
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.completed:
        return 'Completed';
    }
  }
}
