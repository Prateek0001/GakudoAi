import '../models/user_profile.dart';

abstract class DashboardState {
  const DashboardState();
}

class DashboardInitial extends DashboardState {}

class DashboardLoadingState extends DashboardState {}

class DashboardLoadedState extends DashboardState {
  final UserProfile userProfile;

  const DashboardLoadedState(this.userProfile);
}

class DashboardErrorState extends DashboardState {
  final String message;

  const DashboardErrorState(this.message);
} 