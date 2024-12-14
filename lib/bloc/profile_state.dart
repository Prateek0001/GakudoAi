
import 'package:rx_logix/models/profile.dart';


abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoadingState extends ProfileState {}

class ProfileLoadedState extends ProfileState {
  final Profile profile;
  
  ProfileLoadedState(this.profile);
}

class ProfileSavedState extends ProfileState {}

class ProfileErrorState extends ProfileState {
  final String message;
  
  ProfileErrorState(this.message);
} 