part of 'instagram_auth_cubit.dart';

abstract class InstagramAuthState extends Equatable {
  const InstagramAuthState();

  @override
  List<Object> get props => [];
}

class InstagramAuthInitial extends InstagramAuthState {
  const InstagramAuthInitial({this.updateInstagramAccount = false});
  final bool updateInstagramAccount;

  @override
  List<Object> get props => [updateInstagramAccount];
}

class InstagramAuthInProgress extends InstagramAuthState {}

class InstagramAuthUserChanged extends InstagramAuthState {}

class InstagramAuthSuccess extends InstagramAuthState {
  final bool userChanged;

  const InstagramAuthSuccess({this.userChanged = false});

  @override
  List<Object> get props => [userChanged];
}

class InstagramAuthFailure extends InstagramAuthState {
  const InstagramAuthFailure({required this.message});
  final String message;

  @override
  List<Object> get props => [message];
}
