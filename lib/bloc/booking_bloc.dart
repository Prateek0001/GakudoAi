import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rx_logix/bloc/booking_event.dart';
import 'package:rx_logix/bloc/booking_state.dart';
import 'package:rx_logix/services/user_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import '../models/booking.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/booking/booking_repository.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository bookingRepository;
  String currentBookingId = "";

  BookingBloc(this.bookingRepository) : super(BookingInitial()) {
    on<FetchBookingsEvent>(_onFetchBookings);
    on<LoadBookingsEvent>(_onLoadBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<RescheduleBookingEvent>(_onRescheduleBooking);
    on<UpdateBookingIdEvent>((event, emit) => currentBookingId = event.newBookingId);
  }

  Future<void> _onFetchBookings(FetchBookingsEvent event, Emitter<BookingState> emit) async {
    try {
      emit(BookingLoadingState());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.authToken);
      
      if (token == null) throw Exception('Not authenticated');
      
      final bookings = await bookingRepository.fetchBookings(event.username, token);
      emit(BookingsLoadedState(bookings));
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
      final userProfile = await UserService.getCurrentUser();
      if (userProfile != null) {
        add(FetchBookingsEvent(userProfile.username));
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    // TODO: Implement cancel booking
  }

  Future<void> _onRescheduleBooking(
    RescheduleBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    // TODO: Implement reschedule booking
  }

  Future<void> _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    try {
      emit(BookingLoadingState());
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.authToken);
      
      if (token == null) throw Exception('Not authenticated');
      
      final bookingId = await bookingRepository.createBooking(
        username: event.username,
        dateTime: event.dateTime,
        remark: event.remark,
        token: token,
      );
      
      emit(BookingCreatedState(bookingId));
      add(FetchBookingsEvent(event.username));
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }
}
