import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
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
      
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      
      if (profileJson != null) {
        final profileMap = json.decode(profileJson);
        final profile = Profile.fromJson(profileMap);
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