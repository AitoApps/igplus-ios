import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import 'package:gallery_saver/gallery_saver.dart';

import 'package:igshark/domain/entities/ig_data_update.dart';

import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_from_local_use_case.dart';

import 'package:igshark/domain/usecases/get_stories_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
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
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  late SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  StoriesCubit({
    required this.getStories,
    required this.getUser,
    required this.getStoriesFromLocal,
    required this.cacheStoriesToLocal,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
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

      // check if StoriesUser is outdated
      bool isDataOutdated = await checkIfDataOutdated(DataNames.stories.name);

      if (isDataOutdated || (cachedStoriesList.isLeft() || (cachedStoriesList as Right).value == null)) {
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

  Future<bool> checkIfDataOutdated(String dataName) async {
    IgDataUpdate igDataUpdate;
    bool isOutdated = false;

    Either<Failure, IgDataUpdate?> failureOrIgDataUpdate = getIgDataUpdateUseCase.execute(dataName: dataName);
    if (failureOrIgDataUpdate.isLeft() || (failureOrIgDataUpdate as Right).value == null) {
      // if data is not in local, set it as outdated
      await resetIgDataUpdate(dataName);
      isOutdated = true;
    } else {
      igDataUpdate = (failureOrIgDataUpdate as Right).value!;
      // check if data is outdated
      if (igDataUpdate.nextUpdateTime.isBefore(DateTime.now())) {
        await resetIgDataUpdate(dataName);
        isOutdated = true;
      } else {
        isOutdated = false;
      }
    }

    return isOutdated;
  }

  // update IgDataUpdate next update time
  Future<void> resetIgDataUpdate(String dataName) async {
    const nextUpdateInMinutes = 30;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
