part of 'engagement_cubit.dart';

abstract class EngagementState extends Equatable {
  const EngagementState();

  @override
  List<Object> get props => [];
}

class EngagementInitial extends EngagementState {}

class EngagementLoading extends EngagementState {}

class EngagementLoaded extends EngagementState {
  final bool mediaLikersLoaded;
  final bool mediaCommentersLoaded;

  const EngagementLoaded({
    required this.mediaLikersLoaded,
    required this.mediaCommentersLoaded,
  });

  @override
  List<Object> get props => [mediaLikersLoaded, mediaCommentersLoaded];
}

class EngagementFailure extends EngagementState {}
