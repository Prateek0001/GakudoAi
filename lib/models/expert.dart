class Expert {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final double pricePerHour;
  final String imageUrl;
  final List<String> availableSlots;

  Expert({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.pricePerHour,
    required this.imageUrl,
    required this.availableSlots,
  });

  factory Expert.fromMap(Map<String, dynamic> map) {
    return Expert(
      id: map['id'],
      name: map['name'],
      specialization: map['specialization'],
      experience: map['experience'],
      rating: map['rating'].toDouble(),
      pricePerHour: map['pricePerHour'].toDouble(),
      imageUrl: map['imageUrl'],
      availableSlots: List<String>.from(map['availableSlots']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
      'availableSlots': availableSlots,
    };
  }
} 