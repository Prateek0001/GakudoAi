import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/user_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../models/profile.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<SaveProfileEvent>(_onSaveProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoadingState());
      
      final userProfile = await UserService.getCurrentUser();
      
      if (userProfile != null) {
        final profile = Profile(
          fullName: userProfile.fullName,
          email: userProfile.email,
          mobileNumber: userProfile.mobileNumber,
          schoolName: userProfile.schoolName,
          medium: userProfile.medium,
          standard: int.parse(userProfile.standard),
          location: '', // These fields are not in UserProfile
          segment: 'School',
          stream: '',
          fatherProfession: '',
          motherProfession: '',
        );
        emit(ProfileLoadedState(profile));
      } else {
        emit(ProfileInitial());
      }
    } catch (e) {
      emit(ProfileErrorState('Failed to load profile: ${e.toString()}'));
    }
  }

  Future<void> _onSaveProfile(
    SaveProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(ProfileLoadingState());
      
      final profile = Profile(
        fullName: event.fullName,
        email: event.email,
        mobileNumber: event.mobileNumber,
        schoolName: event.schoolName,
        location: event.location,
        segment: event.segment,
        standard: int.parse(event.standard),
        stream: event.stream,
        medium: event.medium,
        fatherProfession: event.fatherProfession,
        motherProfession: event.motherProfession,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toJson()));
      
      emit(ProfileSavedState());
    } catch (e) {
      emit(ProfileErrorState('Failed to save profile: ${e.toString()}'));
    }
  }
} 