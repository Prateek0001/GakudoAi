import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:rx_logix/bloc/booking_event.dart';
import 'package:rx_logix/bloc/booking_state.dart';
import 'package:rx_logix/services/user_service.dart';
import 'dart:convert';
import '../models/booking.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc() : super(BookingInitial()) {
    on<FetchBookingsEvent>(_onFetchBookings);
    on<LoadBookingsEvent>(_onLoadBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
    on<RescheduleBookingEvent>(_onRescheduleBooking);
  }

  Future<void> _onFetchBookings(
    FetchBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.authToken);

      if (token == null) throw Exception('Not authenticated');

      final response = await http.get(
        Uri.parse(
            '${ApiConstants.baseUrl}/api/v1/fetch-booking/?username=${event.username}'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final bookings = (data['booking_list'] as List)
            .map((booking) => Booking.fromJson(booking))
            .toList();
        emit(BookingsLoadedState(bookings));
      } else {
        throw Exception('Failed to fetch bookings');
      }
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

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    try {
      emit(BookingLoadingState());

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageConstants.authToken);

      if (token == null) throw Exception('Not authenticated');

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/booking/'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': event.username,
          'dateTime': event.dateTime.toUtc().toIso8601String(),
          'remark': event.remark,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        emit(BookingCreatedState(data['id']));

        // Immediately fetch updated booking list
        add(FetchBookingsEvent(event.username));
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      emit(BookingErrorState(e.toString()));
    }
  }
}
