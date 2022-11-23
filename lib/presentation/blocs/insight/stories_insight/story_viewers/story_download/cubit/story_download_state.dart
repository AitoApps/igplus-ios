part of 'story_download_cubit.dart';

abstract class StoryDownLoadState extends Equatable {
  const StoryDownLoadState();

  @override
  List<Object> get props => [];
}

class StoryDownLoadInitial extends StoryDownLoadState {}

class StoryDownLoadInProgress extends StoryDownLoadState {}

class StoryDownLoadSuccess extends StoryDownLoadState {
  final String path;
  const StoryDownLoadSuccess({required this.path});
}

class StoryDownLoadFailure extends StoryDownLoadState {
  final String message;
  const StoryDownLoadFailure({required this.message});
}
