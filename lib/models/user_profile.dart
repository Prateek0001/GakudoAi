class UserProfile {
  final String username;
  final String email;
  final String fullName;
  final bool disabled;
  final String role;
  final int standard;
  final String schoolName;
  final String medium;
  final String mobileNumber;
  final String id;

  UserProfile({
    required this.username,
    required this.email,
    required this.fullName,
    required this.disabled,
    required this.role,
    required this.standard,
    required this.schoolName,
    required this.medium,
    required this.mobileNumber,
    required this.id,
  });

  // Factory method to create UserProfile from JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      disabled: json['disabled'] ?? false,
      role: json['role'] ?? '',
      standard: json['standard'] ?? 0,
      schoolName: json['school_name'] ?? '',
      medium: json['medium'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  // Method to convert UserProfile to JSON
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'full_name': fullName,
      'disabled': disabled,
      'role': role,
      'standard': standard,
      'school_name': schoolName,
      'medium': medium,
      'mobile_number': mobileNumber,
      '_id': id,
    };
  }
}
