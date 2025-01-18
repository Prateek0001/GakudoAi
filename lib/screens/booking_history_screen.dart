import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rx_logix/screens/booking_screen.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
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
              return const Center(child: Text('No bookings found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.bookings.length,
              itemBuilder: (context, index) {
                final booking = state.bookings[index];
                return Card(
                  child: ListTile(
                    title: Text(booking.remark),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${_formatDateTime(booking.dateTime)}'),
                        Text('Status: ${booking.status}'),
                      ],
                    ),
                    trailing: booking.status.toLowerCase() == "payment pending"
                        ? SizedBox(
                            width: 120, // Give enough width for the button
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement payment logic
                              },
                              child: const Text('Make Payment'),
                            ),
                          )
                        : null,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BookingDetailsScreen(booking: booking),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          if (state is BookingErrorState) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookingScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
