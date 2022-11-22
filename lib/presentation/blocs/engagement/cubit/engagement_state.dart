part of 'engagement_cubit.dart';

abstract class EngagementState extends Equatable {
  const EngagementState();

  @override
  List<Object> get props => [];
}

class EngagementInitial extends EngagementState {}

class EngagementLoading extends EngagementState {}

class EngagementLoaded extends EngagementState {}
