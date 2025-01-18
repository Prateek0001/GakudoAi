import 'package:equatable/equatable.dart';

abstract class BookingEvent {
  const BookingEvent();
}

class FetchBookingsEvent extends BookingEvent {
  final String username;
  const FetchBookingsEvent(this.username);
}

class LoadBookingsEvent extends BookingEvent {}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  const CancelBookingEvent(this.bookingId);
}

class RescheduleBookingEvent extends BookingEvent {
  final String bookingId;
  final DateTime newDateTime;
  final String timeSlot;

  const RescheduleBookingEvent({
    required this.bookingId,
    required this.newDateTime,
    required this.timeSlot,
  });
}
class UpdateBookingIdEvent extends BookingEvent {
  final String newBookingId;

  UpdateBookingIdEvent(this.newBookingId);
}
class CreateBookingEvent extends BookingEvent {
  final String username;
  final DateTime dateTime;
  final String remark;

  const CreateBookingEvent({
    required this.username,
    required this.dateTime,
    required this.remark,
  });
}
