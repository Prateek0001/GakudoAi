import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../models/booking.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadBookingsEvent>(_onLoadBookings);
    on<CancelBookingEvent>(_onCancelBooking);
    on<RescheduleBookingEvent>(_onRescheduleBooking);
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final booking = Booking(
        id: const Uuid().v4(),
        expertId: event.expertId,
        userId: 'current_user_id', // Replace with actual user ID
        sessionDate: event.sessionDate,
        timeSlot: event.timeSlot,
        amount: event.amount,
        status: 'confirmed',
      );

      // Save booking to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('bookings') ?? [];
      bookingsJson.add(json.encode(booking.toMap()));
      await prefs.setStringList('bookings', bookingsJson);

      emit(BookingSuccessState(booking));
      add(LoadBookingsEvent()); // Reload the bookings list
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }

  Future<void> _onLoadBookings(
    LoadBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('bookings') ?? [];
      
      final bookings = bookingsJson
          .map((jsonStr) => Booking.fromMap(json.decode(jsonStr)))
          .toList();
      
      // Sort bookings by date, most recent first
      bookings.sort((a, b) => b.sessionDate.compareTo(a.sessionDate));

      emit(BookingsLoadedState(bookings));
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('bookings') ?? [];
      
      final bookings = bookingsJson
          .map((jsonStr) => Booking.fromMap(json.decode(jsonStr)))
          .toList();

      // Find and update the booking status
      final updatedBookings = bookings.map((booking) {
        if (booking.id == event.bookingId) {
          return Booking(
            id: booking.id,
            expertId: booking.expertId,
            userId: booking.userId,
            sessionDate: booking.sessionDate,
            timeSlot: booking.timeSlot,
            amount: booking.amount,
            status: 'cancelled',
            createdAt: booking.createdAt,
          );
        }
        return booking;
      }).toList();

      // Save updated bookings
      final updatedBookingsJson = 
          updatedBookings.map((booking) => json.encode(booking.toMap())).toList();
      await prefs.setStringList('bookings', updatedBookingsJson);

      emit(BookingsLoadedState(updatedBookings));
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }

  Future<void> _onRescheduleBooking(
    RescheduleBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final prefs = await SharedPreferences.getInstance();
      final bookingsJson = prefs.getStringList('bookings') ?? [];
      
      final bookings = bookingsJson
          .map((jsonStr) => Booking.fromMap(json.decode(jsonStr)))
          .toList();

      // Find and update the booking
      final updatedBookings = bookings.map((booking) {
        if (booking.id == event.bookingId) {
          return Booking(
            id: booking.id,
            expertId: booking.expertId,
            userId: booking.userId,
            sessionDate: event.newDate,
            timeSlot: event.newTimeSlot,
            amount: booking.amount,
            status: 'confirmed',
            createdAt: booking.createdAt,
          );
        }
        return booking;
      }).toList();

      // Save updated bookings
      final updatedBookingsJson = 
          updatedBookings.map((booking) => json.encode(booking.toMap())).toList();
      await prefs.setStringList('bookings', updatedBookingsJson);

      emit(BookingsLoadedState(updatedBookings));
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }
} 