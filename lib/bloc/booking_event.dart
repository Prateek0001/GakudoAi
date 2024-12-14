import 'package:equatable/equatable.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final String expertId;
  final DateTime sessionDate;
  final String timeSlot;
  final double amount;
  final String paymentId;

  const CreateBookingEvent({
    required this.expertId,
    required this.sessionDate,
    required this.timeSlot,
    required this.amount,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [expertId, sessionDate, timeSlot, amount, paymentId];
}

class LoadBookingsEvent extends BookingEvent {}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;

  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}

class RescheduleBookingEvent extends BookingEvent {
  final String bookingId;
  final DateTime newDate;
  final String newTimeSlot;

  const RescheduleBookingEvent({
    required this.bookingId,
    required this.newDate,
    required this.newTimeSlot,
  });

  @override
  List<Object?> get props => [bookingId, newDate, newTimeSlot];
} 