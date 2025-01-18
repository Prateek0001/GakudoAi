class Booking {
  final String id;
  final String username;
  final DateTime dateTime;
  final DateTime bookingTime;
  final String remark;
  final String status;

  Booking({
    required this.id,
    required this.username,
    required this.dateTime,
    required this.bookingTime,
    required this.remark,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      username: json['username'],
      dateTime: DateTime.parse(json['date_time']),
      bookingTime: DateTime.parse(json['booking_time']),
      remark: json['remark'],
      status: json['status'],
    );
  }
}
