class Profile {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String schoolName;
  final String medium;
  final int standard;
  final String location;
  final String segment;
  final String stream;
  final String fatherProfession;
  final String motherProfession;

  Profile({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.schoolName,
    required this.medium,
    required this.standard,
    required this.location,
    required this.segment,
    required this.stream,
    required this.fatherProfession,
    required this.motherProfession,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      schoolName: json['school_name'] ?? '',
      medium: json['medium'] ?? 'English',
      standard: json['standard'] ?? 10,
      location: json['location'] ?? '',
      segment: json['segment'] ?? 'School',
      stream: json['stream'] ?? '',
      fatherProfession: json['father_profession'] ?? '',
      motherProfession: json['mother_profession'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'email': email,
      'mobile_number': mobileNumber,
      'school_name': schoolName,
      'medium': medium,
      'standard': standard,
      'location': location,
      'segment': segment,
      'stream': stream,
      'father_profession': fatherProfession,
      'mother_profession': motherProfession,
    };
  }
} 