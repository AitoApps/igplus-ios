import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/usecases/get_stories_from_local_use_case.dart';

import 'package:igshark/domain/usecases/get_stories_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_stories_to_local_use_case.dart';
import 'package:path_provider/path_provider.dart';
import 'package:story_view/story_view.dart';

import 'package:igshark/data/failure.dart';
import 'package:igshark/domain/entities/story.dart';

import '../../../../../app/constants/media_constants.dart';

part 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  final GetStoriesUseCase getStories;
  final GetUserUseCase getUser;
  final GetStoriesFromLocalUseCase getStoriesFromLocal;
  final CacheStoriesToLocalUseCase cacheStoriesToLocal;
  StoriesCubit({
    required this.getStories,
    required this.getUser,
    required this.getStoriesFromLocal,
    required this.cacheStoriesToLocal,
  }) : super(StoriesInitial());

  void init({required StoryOwner storyOwner}) async {
    emit(StoriesLoading());

    final StoryController controller = StoryController();

    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      final failure = (failureOrCurrentUser as Left).value;
      if (failure is UserAuthenticationFailure) {
        emit(StoriesFailure(failure: failure));
      } else {
        emit(StoriesLoaded(stories: const [], controller: controller, storyOwner: storyOwner));
      }
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;

      Either<Failure, List<Story>?> cachedStoriesList = await getStoriesFromLocal.execute(
        boxKey: StoriesUser.boxKey,
        pageKey: 0,
        pageSize: 10,
        searchTerm: null,
        type: "getStoriesByUser",
        ownerId: storyOwner.id,
      );
      if (cachedStoriesList.isLeft() || (cachedStoriesList as Right).value == null) {
        // get stories user
        final failureOrStories =
            await getStories.execute(storyOwnerId: storyOwner.id, igHeaders: currentUser.igHeaders);
        if (failureOrStories.isLeft()) {
          final failure = (failureOrStories as Left).value;
          if (failure is InstagramSessionFailure) {
            emit(StoriesFailure(failure: failure));
          } else {
            emit(StoriesLoaded(stories: const [], controller: controller, storyOwner: storyOwner));
          }
        } else {
          // save stories to local
          await cacheStoriesToLocal.execute(
              boxKey: StoriesUser.boxKey, storiesList: (failureOrStories as Right).value!, ownerId: storyOwner.id);
          final List<Story> stories = (failureOrStories as Right).value;
          emit(StoriesLoaded(stories: stories, controller: controller, storyOwner: storyOwner));
        }
      } else {
        final List<Story> stories = (cachedStoriesList as Right).value;
        emit(StoriesLoaded(stories: stories, controller: controller, storyOwner: storyOwner));
      }
    }
  }
}
