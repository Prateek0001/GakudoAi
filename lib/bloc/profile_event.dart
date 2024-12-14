import 'package:equatable/equatable.dart';


abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {}

class SaveProfileEvent extends ProfileEvent {
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

  const SaveProfileEvent({
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

  @override
  List<Object?> get props => [
        fullName,
        email,
        mobileNumber,
        schoolName,
        location,
        segment,
        standard,
        stream,
        medium,
        fatherProfession,
        motherProfession,
      ];
} 