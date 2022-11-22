part of 'media_list_cubit.dart';

abstract class MediaListState extends Equatable {
  const MediaListState();

  @override
  List<Object> get props => [];
}

class MediaListInitial extends MediaListState {}

class MediaListLoading extends MediaListState {}

class MediaListFailure extends MediaListState {
  final String message;

  const MediaListFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class MediaListSuccess extends MediaListState {}
