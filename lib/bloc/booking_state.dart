import 'package:equatable/equatable.dart';
import '../models/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoadingState extends BookingState {}

class BookingSuccessState extends BookingState {
  final Booking booking;

  const BookingSuccessState(this.booking);

  @override
  List<Object?> get props => [booking];
}

class BookingsLoadedState extends BookingState {
  final List<Booking> bookings;

  const BookingsLoadedState(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class BookingErrorState extends BookingState {
  final String message;

  const BookingErrorState(this.message);

  @override
  List<Object?> get props => [message];
} 