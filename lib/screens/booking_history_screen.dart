import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../models/booking.dart';
import 'booking_details_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BookingBloc()..add(LoadBookingsEvent()),
      child: const BookingHistoryView(),
    );
  }
}

class BookingHistoryView extends StatelessWidget {
  const BookingHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookingsLoadedState) {
            if (state.bookings.isEmpty) {
              return const Center(
                child: Text('No bookings found'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return BookingCard(booking: booking);
              },
            );
          }

          if (state is BookingErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text('Session on ${_formatDate(booking.sessionDate)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${booking.timeSlot}'),
            Text('Status: ${booking.status}'),
            Text('Amount: ₹${booking.amount}'),
          ],
        ),
        trailing: _buildActionButton(context),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(booking: booking),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (booking.status == 'confirmed') {
      return PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'reschedule',
            child: Text('Reschedule'),
          ),
          const PopupMenuItem(
            value: 'cancel',
            child: Text('Cancel'),
          ),
        ],
        onSelected: (value) {
          if (value == 'cancel') {
            _showCancelDialog(context);
          } else if (value == 'reschedule') {
            _showRescheduleDialog(context);
          }
        },
      );
    }
    return const SizedBox();
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              context.read<BookingBloc>().add(CancelBookingEvent(booking.id));
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(BuildContext context) {
    DateTime? selectedDate;
    String? selectedTimeSlot;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: booking.sessionDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  selectedDate = date;
                }
              },
              child: const Text('Select New Date'),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              hint: const Text('Select New Time'),
              value: selectedTimeSlot,
              items: const [
                '9:00 AM',
                '10:00 AM',
                '11:00 AM',
                '2:00 PM',
                '3:00 PM',
                '4:00 PM',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                selectedTimeSlot = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (selectedDate != null && selectedTimeSlot != null) {
                context.read<BookingBloc>().add(
                      RescheduleBookingEvent(
                        bookingId: booking.id,
                        newDate: selectedDate!,
                        newTimeSlot: selectedTimeSlot!,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Reschedule'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
