import 'package:equatable/equatable.dart';

abstract class SignupEvent extends Equatable {
  const SignupEvent();
}

class SignupSubmitEvent extends SignupEvent {
  final String email;
  final String fullName;
  final String username;
  final String password;
  final String mobileNumber;
  final String standard;

  const SignupSubmitEvent({
    required this.email,
    required this.fullName,
    required this.username,
    required this.password,
    required this.mobileNumber,
    required this.standard,
  });

  @override
  List<Object> get props =>
      [email, fullName, username, password, mobileNumber, standard];
}
