class ProfileData {
  final String fullName;
  final String email;
  final String mobileNumber;
  final String schoolName;
  final String location;
  final String segment;
  final String standard;
  final String stream;
  final String medium;
  final String fatherProfession;
  final String motherProfession;

  ProfileData({
    required this.fullName,
    required this.email,
    required this.mobileNumber,
    required this.schoolName,
    required this.location,
    required this.segment,
    required this.standard,
    required this.stream,
    required this.medium,
    required this.fatherProfession,
    required this.motherProfession,
  });

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      mobileNumber: map['mobileNumber'] ?? '',
      schoolName: map['schoolName'] ?? '',
      location: map['location'] ?? '',
      segment: map['segment'] ?? '',
      standard: map['standard'] ?? '',
      stream: map['stream'] ?? '',
      medium: map['medium'] ?? '',
      fatherProfession: map['fatherProfession'] ?? '',
      motherProfession: map['motherProfession'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'mobileNumber': mobileNumber,
      'schoolName': schoolName,
      'location': location,
      'segment': segment,
      'standard': standard,
      'stream': stream,
      'medium': medium,
      'fatherProfession': fatherProfession,
      'motherProfession': motherProfession,
    };
  }
} 