import 'package:equatable/equatable.dart';
import '../models/booking.dart';

abstract class BookingState {
  const BookingState();
}

class BookingInitial extends BookingState {}

class BookingLoadingState extends BookingState {}

class BookingsLoadedState extends BookingState {
  final List<Booking> bookings;
  const BookingsLoadedState(this.bookings);
}

class BookingSuccessState extends BookingState {}

class BookingErrorState extends BookingState {
  final String message;
  const BookingErrorState(this.message);
}

class BookingCreatedState extends BookingState {
  final String bookingId;
  const BookingCreatedState(this.bookingId);
}
