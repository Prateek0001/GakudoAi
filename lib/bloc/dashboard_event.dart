import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardEvent extends DashboardEvent {}

class LogoutEvent extends DashboardEvent {}

class LoadUserProfileEvent extends DashboardEvent {} 