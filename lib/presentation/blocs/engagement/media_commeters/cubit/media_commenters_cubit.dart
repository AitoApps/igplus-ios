import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/data/models/media_commenters_model.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_commenters.dart';
import 'package:igshark/domain/entities/user.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_media_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/save_media_commenters_to_local_use_case.dart';

part 'media_commeters_state.dart';

class MediaCommentersCubit extends Cubit<MediaCommentersState> {
  final GetMediaCommentersUseCase getMediaCommentersUseCase;
  final GetMediaFromLocalUseCase getMediaFromLocalUseCase;
  final CacheMediaCommentersToLocalUseCase cacheMediaCommentersToLocalUseCase;
  final GetMediaCommentersFromLocalUseCase getMediaCommentersFromLocalUseCase;
  final GetFriendsFromLocalUseCase getFriendsFromLocalUseCase;
  final GetUserUseCase getUser;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  MediaCommentersCubit({
    required this.getMediaCommentersUseCase,
    required this.getUser,
    required this.getMediaFromLocalUseCase,
    required this.cacheMediaCommentersToLocalUseCase,
    required this.getMediaCommentersFromLocalUseCase,
    required this.getFriendsFromLocalUseCase,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(MediaCommentersInitial());

  Future<List<MediaCommenter>?> init({
    required String boxKey,
    int pageKey = 0,
    required int pageSize,
    String? searchTerm,
  }) async {
    emit(MediaCommentersLoading());
    List<MediaCommenter> mediaCommentersList = [];
    List<Media> mediaList;

    // check if madiaCommenters data is outdated
    bool isDataOutdated = await checkIfDataOutdated(DataNames.mediaCommenters.name);

    if (isDataOutdated) {
// get media list from local
      Either<Failure, List<Media>?>? mediaListOrFailure =
          await getMediaFromLocalUseCase.execute(boxKey: Media.boxKey, pageKey: 0, pageSize: 100);

      if (mediaListOrFailure != null && mediaListOrFailure.isRight()) {
        mediaList = mediaListOrFailure.getOrElse(() => null) ?? [];

        for (var media in mediaList) {
          // get media commenters from instagram
          List<MediaCommenter>? mediaCommenters =
              await getMediaCommenters(mediaId: media.id, boxKey: MediaCommenter.boxKey);
          if (mediaCommenters != null) {
            mediaCommentersList.addAll(mediaCommenters);
            // save media commenters to local
            await cacheMediaCommentersToLocalUseCase.execute(
                boxKey: MediaCommenter.boxKey, mediaCommentersList: mediaCommenters);
          }

          await Future.delayed(const Duration(seconds: 2));
        }
        emit(MediaCommentersSuccess(mediaCommenters: mediaCommentersList, pageKey: 0));
        return mediaCommentersList;
      }
    } else {
      // get media commenters from local
      final mediaCommentersFromLocal = getMediaCommentersFromLocalUseCase.execute(
          boxKey: MediaCommenter.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

      if (mediaCommentersFromLocal.isRight() && mediaCommentersFromLocal.getOrElse(() => null) != null) {
        mediaCommentersList = mediaCommentersFromLocal.getOrElse(() => null)!;
        emit(MediaCommentersSuccess(mediaCommenters: mediaCommentersList, pageKey: 0));
        return mediaCommentersList;
      }

      if (mediaCommentersList.isEmpty) {
        // get media list from local
        Either<Failure, List<Media>?>? mediaListOrFailure =
            await getMediaFromLocalUseCase.execute(boxKey: Media.boxKey, pageKey: 0, pageSize: 100);

        if (mediaListOrFailure != null && mediaListOrFailure.isRight()) {
          mediaList = mediaListOrFailure.getOrElse(() => null) ?? [];

          for (var media in mediaList) {
            // get media commenters from instagram
            List<MediaCommenter>? mediaCommenters =
                await getMediaCommenters(mediaId: media.id, boxKey: MediaCommenter.boxKey);
            if (mediaCommenters != null) {
              mediaCommentersList.addAll(mediaCommenters);
              // save media commenters to local
              await cacheMediaCommentersToLocalUseCase.execute(
                  boxKey: MediaCommenter.boxKey, mediaCommentersList: mediaCommenters);
            }

            await Future.delayed(const Duration(seconds: 2));
          }
          emit(MediaCommentersSuccess(mediaCommenters: mediaCommentersList, pageKey: 0));
          return mediaCommentersList;
        }
      }
    }
    return null;
  }

  Future<List<MediaCommenter>?> getMediaCommenters({required String mediaId, required String boxKey}) async {
    emit(MediaCommentersLoading());
    // get header current user header
    User currentUser = await getCurrentUser();

    Either<Failure, List<MediaCommenter>> mediaCommentersOrFailure =
        await getMediaCommentersUseCase.execute(mediaId: mediaId, igHeaders: currentUser.igHeaders);
    if (mediaCommentersOrFailure.isLeft()) {
      emit(const MediaCommentersFailure(message: 'Error getting media commenters list'));
      return null;
    } else {
      List<MediaCommenter> mediaCommenters;
      mediaCommenters = mediaCommentersOrFailure.getOrElse(() => []);
      emit(MediaCommentersSuccess(mediaCommenters: mediaCommenters, pageKey: 0));
      return mediaCommenters;
    }
  }

  // get users with most comments
  Future<List<MediaCommenters>?> getMostCommentsUsers(
      {required String boxKey,
      required int pageKey,
      required int pageSize,
      String? searchTerm,
      bool reverse = false}) async {
    emit(MediaCommentersLoading());
    List<MediaCommenter> mediaCommentersList = [];

    // get media commenters from local
    final mediaCommentersFromLocal = getMediaCommentersFromLocalUseCase.execute(
        boxKey: MediaCommenter.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaCommentersFromLocal.isRight() && mediaCommentersFromLocal.getOrElse(() => null) != null) {
      mediaCommentersList = mediaCommentersFromLocal.getOrElse(() => null)!;
      emit(MediaCommentersSuccess(mediaCommenters: mediaCommentersList, pageKey: 0));

      // group by user id
      return await getMostCommentsFromMediaComments(mediaCommentersList, pageKey, pageSize, reverse);
    }

    return null;
  }

  // get users comments where user is not friend
  Future<List<MediaCommenters>?> getCommentsUsersButNotFollow(
      {required String boxKey, required int pageKey, required int pageSize, String? searchTerm}) async {
    emit(MediaCommentersLoading());
    List<MediaCommenter> mediaCommenterList = [];
    List<MediaCommenters> mediaCommentersList = [];

    // get media commenters from local
    final mediaCommentersFromLocal = getMediaCommentersFromLocalUseCase.execute(
        boxKey: MediaCommenter.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaCommentersFromLocal.isRight() && mediaCommentersFromLocal.getOrElse(() => null) != null) {
      mediaCommenterList = mediaCommentersFromLocal.getOrElse(() => null)!;

      mediaCommenterList = await deleteMediaCommentersThatFollowYou(mediaCommenterList);

      // group by user id
      mediaCommentersList = await getMostCommentsFromMediaComments(mediaCommenterList, pageKey, pageSize, false);

      // sort by likesCount
      mediaCommentersList.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));

      // paginate
      int? startKey;
      int? endKey;
      startKey = pageKey;
      endKey = startKey + pageSize;
      if (endKey > mediaCommentersList.length - 1) {
        endKey = mediaCommentersList.length;
      }
      mediaCommentersList = mediaCommentersList.sublist(startKey, endKey);

      emit(MediaCommentersSuccess(mediaCommenters: mediaCommenterList, pageKey: 0));

      return mediaCommentersList;
    }

    return null;
  }

  Future<List<MediaCommenters>> getMostCommentsFromMediaComments(
      List<MediaCommenter> mediaCommentersList, int pageKey, int pageSize, bool reverse) async {
    // group by user id
    Map<String, List<MediaCommenter>> mediaCommentersMap = {};
    for (var mediaCommenter in mediaCommentersList) {
      if (mediaCommentersMap.containsKey(mediaCommenter.user.igUserId.toString())) {
        mediaCommentersMap[mediaCommenter.user.igUserId.toString()]!.add(mediaCommenter);
      } else {
        mediaCommentersMap[mediaCommenter.user.igUserId.toString()] = [mediaCommenter];
      }
    }

    // get followers list
    List<Friend> followersList = [];
    Either<Failure, List<Friend>?>? friendsListOfFailure =
        await getFriendsFromLocalUseCase.execute(boxKey: "followers", pageKey: 0, pageSize: 10000);
    if (friendsListOfFailure != null && friendsListOfFailure.isRight()) {
      followersList = friendsListOfFailure.getOrElse(() => null) ?? [];
    }
    // get following list
    List<Friend> followingList = [];
    Either<Failure, List<Friend>?>? followingListOfFailure =
        await getFriendsFromLocalUseCase.execute(boxKey: "followings", pageKey: 0, pageSize: 10000);
    if (followingListOfFailure != null && followingListOfFailure.isRight()) {
      followingList = followingListOfFailure.getOrElse(() => null) ?? [];
    }

    // format MedialCommenter List to MediaCommenters
    List<MediaCommenters> mediaCommenters = [];
    mediaCommentersMap.forEach((key, value) {
      // check if user is following me
      bool following = false;
      bool followedBy = false;
      if (followersList.indexWhere((element) => element.igUserId == int.parse(key)) != -1) {
        followedBy = true;
      }
      if (followingList.indexWhere((element) => element.igUserId == int.parse(key)) != -1) {
        following = true;
      }
      mediaCommenters.add(MediaCommentersModel.fromMediaCommenter(value, key, followedBy, following).toEntity());
    });

    // sort by commentsCount
    if (reverse) {
      mediaCommenters.sort((a, b) => a.commentsCount.compareTo(b.commentsCount));
    } else {
      mediaCommenters.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
    }

    // paginate
    int? startKey;
    int? endKey;
    startKey = pageKey;
    endKey = startKey + pageSize;
    if (endKey > mediaCommenters.length - 1) {
      endKey = mediaCommenters.length;
    }
    mediaCommenters = mediaCommenters.sublist(startKey, endKey);

    return mediaCommenters;
  }

  Future<User> getCurrentUser() async {
    late User currentUser;
    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      emit(const MediaCommentersFailure(message: 'Failed to get user info'));
    } else {
      currentUser = (failureOrCurrentUser as Right).value;
    }
    return currentUser;
  }

  Future<List<MediaCommenter>> deleteMediaCommentersThatFollowYou(List<MediaCommenter> mediaLikersList) async {
    // get followers list
    List<Friend> followersList = [];
    Either<Failure, List<Friend>?>? friendsListOfFailure =
        await getFriendsFromLocalUseCase.execute(boxKey: "followers", pageKey: 0, pageSize: 10000);

    if (friendsListOfFailure != null && friendsListOfFailure.isRight()) {
      followersList = friendsListOfFailure.getOrElse(() => null) ?? [];
    }

    // delete media likers that follow you
    mediaLikersList
        .removeWhere((element) => followersList.indexWhere((friend) => friend.igUserId == element.user.igUserId) != -1);

    return mediaLikersList;
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
    const nextUpdateInMinutes = 60 * 2;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }
}
