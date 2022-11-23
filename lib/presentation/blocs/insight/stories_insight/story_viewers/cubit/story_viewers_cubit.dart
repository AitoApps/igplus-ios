import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/data/models/stories_viewer_model.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/stories_viewers.dart';
import 'package:igshark/domain/entities/story_viewer.dart';
import 'package:igshark/domain/usecases/follow_user_use_case.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_story_viewers_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_story_viewers_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/save_story_viewers_to_local_use_case.dart';
import 'package:igshark/domain/usecases/unfollow_user_use_case%20copy.dart';

part 'story_viewers_state.dart';

class StoryViewersCubit extends Cubit<StoryViewersState> {
  final GetStoryViewersFromLocalUseCase getStoryViewersFromLocal;
  final GetStoryViewersUseCase getStoryViewers;
  final FollowUserUseCase followUserUseCase;
  final UnfollowUserUseCase unfollowUserUseCase;
  final CacheStoryViewersToLocalUseCase cacheStoryViewersToLocalUseCase;
  final GetUserUseCase getUser;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  StoryViewersCubit({
    required this.getStoryViewersFromLocal,
    required this.getStoryViewers,
    required this.followUserUseCase,
    required this.getUser,
    required this.unfollowUserUseCase,
    required this.cacheStoryViewersToLocalUseCase,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(StoryViewersInitial());

  Future<List<StoryViewer>?> getStoryViewersList({
    required String mediaId,
    required String type,
    required int pageKey,
    int? pageSize,
    String? searchTerm,
  }) async {
    List<StoryViewer> storyViewersList;

    storyViewersList = await _getStoryViewersListFromLocal(
        mediaId: mediaId, type: type, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    // check if stories list is outdated
    bool isDataOutdated = await checkIfDataOutdated(DataNames.storyViwers.name);

    if (storyViewersList.isEmpty || isDataOutdated) {
      storyViewersList = await getStoryViewersListFromInstagram(mediaId: mediaId);
      // save story viewers list to local
      if (storyViewersList.isNotEmpty) {
        await cacheStoryViewersToLocalUseCase.execute(storiesViewersList: storyViewersList, boxKey: StoryViewer.boxKey);
        // reset IgDataUpdate
        await resetIgDataUpdate(DataNames.storyViwers.name);
      }
      return storyViewersList;
    } else {
      emit(StoryViewersSuccess(storyViewersList: storyViewersList, pageKey: pageKey));
      return storyViewersList;
    }
  }

  // get story viewers list from local
  Future<List<StoryViewer>> _getStoryViewersListFromLocal({
    required String mediaId,
    required String type,
    int? pageKey,
    int? pageSize,
    String? searchTerm,
  }) async {
    emit(StoryViewersLoading());
    final failureOrStoryViewersList = await getStoryViewersFromLocal.execute(
      boxKey: type,
      mediaId: mediaId,
      pageKey: pageKey,
      pageSize: pageSize,
      searchTerm: searchTerm,
    );
    failureOrStoryViewersList.fold(
      (failure) => null,
      (storyViewersList) => storyViewersList,
    );

    if (failureOrStoryViewersList.isLeft()) {
      return [];
    } else {
      return (failureOrStoryViewersList as Right).value;
    }
  }

  // get story viewers list from instagram
  Future<List<StoryViewer>> getStoryViewersListFromInstagram({required String mediaId}) async {
    emit(StoryViewersLoading());
    // get header
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return [];
    }
    final currentUser = (failureOrCurrentUser as Right).value;
    // get story viewers list
    final failureOrStoryViewersList = await getStoryViewers.execute(mediaId: mediaId, igHeaders: currentUser.igHeaders);
    if (failureOrStoryViewersList.isLeft()) {
      return [];
    } else {
      // return viewers list
      return (failureOrStoryViewersList as Right).value;
    }
  }

  // follow user
  Future<bool> followUser({required int userId}) async {
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return false;
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;
      final failureOrSuccess = await followUserUseCase.execute(userId: userId, igHeaders: currentUser.igHeaders);

      if (failureOrSuccess.isLeft()) {
        return false;
      } else {
        return true;
      }
    }
  }

  // unfollow user
  Future<bool> unfollowUser({required int userId}) async {
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      return false;
    } else {
      final currentUser = (failureOrCurrentUser as Right).value;
      final failureOrSuccess = await unfollowUserUseCase.execute(userId: userId, igHeaders: currentUser.igHeaders);

      if (failureOrSuccess.isLeft()) {
        return false;
      } else {
        return true;
      }
    }
  }

  // get top viewers list
  Future<List<StoriesViewer>?> getTopViewersList() async {
    final failureOrStoryViewersList = await getStoryViewersFromLocal.execute(
      boxKey: StoryViewer.boxKey,
      pageKey: 0,
      pageSize: 10,
      searchTerm: null,
    );
    if (failureOrStoryViewersList.isLeft() || (failureOrStoryViewersList as Right).value == null) {
      return null;
    } else {
      List<StoryViewer> storyViewersList = (failureOrStoryViewersList as Right).value;
      Map<String, List<StoryViewer>> topViewersMap = {};
      for (var storyViewer in storyViewersList) {
        if (topViewersMap.containsKey(storyViewer.id.split('_')[2])) {
          topViewersMap[storyViewer.id.split('_')[2]]!.add(storyViewer);
        } else {
          topViewersMap[storyViewer.id.split('_')[2]] = [storyViewer];
        }
      }

      List<StoriesViewer> storiesTopViewersList = [];
      for (var value in topViewersMap.values) {
        storiesTopViewersList.add(StoriesViewerModel.fromJson(value).toEntity());
      }

      // sort by number of stories viewed
      storiesTopViewersList.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      return storiesTopViewersList;
    }
  }

  // get viewers not following you back
  Future<List<StoriesViewer>?> getViewersNotFollowingYouBack() async {
    final failureOrStoryViewersList = await getStoryViewersFromLocal.execute(
      boxKey: StoryViewer.boxKey,
      pageKey: 0,
      pageSize: 10,
      searchTerm: null,
    );
    if (failureOrStoryViewersList.isLeft() || (failureOrStoryViewersList as Right).value == null) {
      return null;
    } else {
      List<StoryViewer> storyViewersList = (failureOrStoryViewersList as Right).value;
      Map<String, List<StoryViewer>> viewersNotFollowingYou = {};
      for (var storyViewer in storyViewersList) {
        if (storyViewer.followedBy == false) {
          if (viewersNotFollowingYou.containsKey(storyViewer.id.split('_')[2])) {
            viewersNotFollowingYou[storyViewer.id.split('_')[2]]!.add(storyViewer);
          } else {
            viewersNotFollowingYou[storyViewer.id.split('_')[2]] = [storyViewer];
          }
        }
      }

      List<StoriesViewer> storiesTopViewersList = [];
      for (var value in viewersNotFollowingYou.values) {
        storiesTopViewersList.add(StoriesViewerModel.fromJson(value).toEntity());
      }

      // sort by number of stories viewed
      storiesTopViewersList.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      return storiesTopViewersList;
    }
  }

  // get viewers you don't follow
  Future<List<StoriesViewer>?> getViewersYouDontFollow() async {
    final failureOrStoryViewersList = await getStoryViewersFromLocal.execute(
      boxKey: StoryViewer.boxKey,
      pageKey: 0,
      pageSize: 10,
      searchTerm: null,
    );
    if (failureOrStoryViewersList.isLeft() || (failureOrStoryViewersList as Right).value == null) {
      return null;
    } else {
      List<StoryViewer> storyViewersList = (failureOrStoryViewersList as Right).value;
      Map<String, List<StoryViewer>> viewersNotFollowingYou = {};
      for (var storyViewer in storyViewersList) {
        if (storyViewer.following == false) {
          if (viewersNotFollowingYou.containsKey(storyViewer.id.split('_')[2])) {
            viewersNotFollowingYou[storyViewer.id.split('_')[2]]!.add(storyViewer);
          } else {
            viewersNotFollowingYou[storyViewer.id.split('_')[2]] = [storyViewer];
          }
        }
      }

      List<StoriesViewer> storiesTopViewersList = [];
      for (var value in viewersNotFollowingYou.values) {
        storiesTopViewersList.add(StoriesViewerModel.fromJson(value).toEntity());
      }

      // sort by number of stories viewed
      storiesTopViewersList.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      return storiesTopViewersList;
    }
  }

  Future<bool> checkIfDataOutdated(String dataName) async {
    IgDataUpdate igDataUpdate;
    bool isOutdated = false;

    Either<Failure, IgDataUpdate?> failureOrIgDataUpdate = getIgDataUpdateUseCase.execute(dataName: dataName);
    if (failureOrIgDataUpdate.isLeft() || (failureOrIgDataUpdate as Right).value == null) {
      // if data is not in local, set it as outdated
      isOutdated = true;
    } else {
      igDataUpdate = (failureOrIgDataUpdate as Right).value!;
      // check if data is outdated
      if (igDataUpdate.nextUpdateTime.isBefore(DateTime.now())) {
        isOutdated = true;
      } else {
        isOutdated = false;
      }
    }

    return isOutdated;
  }

  // update IgDataUpdate next update time
  Future<void> resetIgDataUpdate(String dataName) async {
    const nextUpdateInMinutes = 60 * 1;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
