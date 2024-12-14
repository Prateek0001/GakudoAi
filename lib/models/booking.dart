class Booking {
  final String id;
  final String expertId;
  final String userId;
  final DateTime sessionDate;
  final String timeSlot;
  final double amount;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.expertId,
    required this.userId,
    required this.sessionDate,
    required this.timeSlot,
    required this.amount,
    required this.status,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      expertId: map['expertId'],
      userId: map['userId'],
      sessionDate: DateTime.parse(map['sessionDate']),
      timeSlot: map['timeSlot'],
      amount: map['amount'].toDouble(),
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expertId': expertId,
      'userId': userId,
      'sessionDate': sessionDate.toIso8601String(),
      'timeSlot': timeSlot,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 