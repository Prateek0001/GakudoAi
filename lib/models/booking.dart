class Booking {
  final String id;
  final String username;
  final DateTime dateTime;
  final String remark;
  final String status;

  Booking({
    required this.id,
    required this.username,
    required this.dateTime,
    required this.remark,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      username: json['username'],
      dateTime: DateTime.parse(json['date_time']),
      remark: json['remark'],
      status: json['status'],
    );
  }
}
