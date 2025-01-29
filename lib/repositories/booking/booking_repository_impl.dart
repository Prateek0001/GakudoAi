import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../constants/api_constants.dart';
import '../../models/booking.dart';
import 'booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  @override
  Future<List<Booking>> fetchBookings(String username, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.fetchBookingsEndpoint}/?username=$username'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['booking_list'] as List)
            .map((booking) => Booking.fromJson(booking))
            .toList();
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<String> createBooking({
    required String username,
    required DateTime dateTime,
    required String remark,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.createBookingEndpoint}'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': "${username}_${const Uuid().v4()}",
          'username': username,
          'dateTime': dateTime.toUtc().toIso8601String(),
          'bookingTime': DateTime.now().toUtc().toIso8601String(),
          'remark': remark,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      } else {
        throw Exception('Failed to create booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelBooking(String bookingId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.cancelBookingEndpoint}'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to cancel booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  @override
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String timeSlot,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.rescheduleBookingEndpoint}'),
        headers: {
          'accept': 'application/json',
          'api-key': token,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'newDateTime': newDateTime.toUtc().toIso8601String(),
          'timeSlot': timeSlot,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to reschedule booking');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }
}
