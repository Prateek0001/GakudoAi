class RegisterResponse {
  final bool disabled;
  final String email;
  final String fullName;
  final String medium;
  final String mobileNumber;
  final String schoolName;
  final int standard;
  final String username;

  RegisterResponse({
    required this.disabled,
    required this.email,
    required this.fullName,
    required this.medium,
    required this.mobileNumber,
    required this.schoolName,
    required this.standard,
    required this.username,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      disabled: json['disabled'] ?? false,
      email: json['email'],
      fullName: json['full_name'],
      medium: json['medium'],
      mobileNumber: json['mobile_number'],
      schoolName: json['school_name'],
      standard: json['standard'],
      username: json['username'],
    );
  }
} 