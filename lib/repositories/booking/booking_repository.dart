import '../../models/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> fetchBookings(String username, String token);
  Future<String> createBooking({
    required String username,
    required DateTime dateTime,
    required String remark,
    required String token,
  });
  Future<void> cancelBooking(String bookingId, String token);
  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDateTime,
    required String timeSlot,
    required String token,
  });
}
