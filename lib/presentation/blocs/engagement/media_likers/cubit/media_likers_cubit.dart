import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/data/models/media_likers_model.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/media_likers.dart';
import 'package:igshark/domain/entities/user.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_media_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_use_case.dart';
import 'package:igshark/domain/usecases/get_user_feed_use_case.dart';
import 'package:igshark/domain/usecases/get_user_use_case.dart';
import 'package:igshark/domain/usecases/get_who_admires_you_from_local_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/save_media_likers_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_media_to_local_use_case.dart';

part 'media_likers_state.dart';

class MediaLikersCubit extends Cubit<MediaLikersState> {
  final GetMediaLikersUseCase getMediaLikersUseCase;
  final GetMediaFromLocalUseCase getMediaFromLocalUseCase;
  final CacheMediaLikersToLocalUseCase cacheMediaLikersToLocalUseCase;
  final GetMediaLikersFromLocalUseCase getMediaLikersFromLocalUseCase;
  final GetFriendsFromLocalUseCase getFriendsFromLocalUseCase;
  final GetUserUseCase getUser;
  final CacheMediaToLocalUseCase cacheMediaToLocal;
  final GetUserFeedUseCase getUserFeed;
  final GetWhoAdmiresYouFromLocalUseCase getWhoAdmiresYouFromLocalUseCase;
  final GetIgDataUpdateUseCase getIgDataUpdateUseCase;
  final SaveIgDataUpdateUseCase saveIgDataUpdateUseCase;
  MediaLikersCubit({
    required this.getMediaLikersUseCase,
    required this.getUser,
    required this.getMediaFromLocalUseCase,
    required this.cacheMediaLikersToLocalUseCase,
    required this.getMediaLikersFromLocalUseCase,
    required this.getFriendsFromLocalUseCase,
    required this.cacheMediaToLocal,
    required this.getUserFeed,
    required this.getWhoAdmiresYouFromLocalUseCase,
    required this.getIgDataUpdateUseCase,
    required this.saveIgDataUpdateUseCase,
  }) : super(MediaLikersInitial());

  Future<List<MediaLiker>?> init({
    required String boxKey,
    int pageKey = 0,
    required int pageSize,
    String? searchTerm,
  }) async {
    emit(MediaLikersLoading());
    List<MediaLiker> mediaLikersList = [];
    List<Media> mediaList;

    // check if madiaLikers data is outdated
    bool isDataOutdated = await checkIfDataOutdated(DataNames.mediaLikers.name);

    mediaLikersList = _getMedialLikersFromLocal(pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaLikersList.isEmpty || isDataOutdated) {
      // get media list from local
      Either<Failure, List<Media>?>? mediaListOrFailure =
          await getMediaFromLocalUseCase.execute(boxKey: Media.boxKey, pageKey: 0, pageSize: 100);

      if (mediaListOrFailure != null && mediaListOrFailure.isRight()) {
        mediaList = mediaListOrFailure.getOrElse(() => null) ?? [];

        for (var media in mediaList) {
          // get media likers from instagram
          List<MediaLiker>? mediaLikers = await getMediaLikers(mediaId: media.id, boxKey: MediaLiker.boxKey);
          if (mediaLikers != null) {
            mediaLikersList = [];
            mediaLikersList.addAll(mediaLikers);
            // save media likers to local
            await cacheMediaLikersToLocalUseCase.execute(boxKey: MediaLiker.boxKey, mediaLikersList: mediaLikers);
            // reset IgDataUpdate
            await resetIgDataUpdate(DataNames.mediaLikers.name);
          }

          await Future.delayed(const Duration(seconds: 2));
        }
        emit(MediaLikersSuccess(mediaLikers: mediaLikersList, pageKey: 0));
        return mediaLikersList;
      } else {
        emit(const MediaLikersFailure(message: "We can't load media list, try again later"));
        return null;
      }
    }

    return null;
  }

  Future<List<MediaLiker>?> getMediaLikers({required String mediaId, required String boxKey}) async {
    emit(MediaLikersLoading());
    // get header current user header
    User currentUser = await getCurrentUser();

    Either<Failure, List<MediaLiker>> mediaLikersOrFailure =
        await getMediaLikersUseCase.execute(mediaId: mediaId, igHeaders: currentUser.igHeaders);
    if (mediaLikersOrFailure.isLeft()) {
      emit(const MediaLikersFailure(message: 'Error getting media likers list'));
      return null;
    } else {
      List<MediaLiker> mediaLikers;
      mediaLikers = mediaLikersOrFailure.getOrElse(() => []);
      emit(MediaLikersSuccess(mediaLikers: mediaLikers, pageKey: 0));
      return mediaLikers;
    }
  }

  // get users with most likes
  Future<List<MediaLikers>?> getMostLikesUsers(
      {required String boxKey,
      required int pageKey,
      required int pageSize,
      String? searchTerm,
      bool reverse = false}) async {
    emit(MediaLikersLoading());
    List<MediaLiker> mediaLikersList = [];

    // get media likers from local
    final mediaLikersFromLocal = getMediaLikersFromLocalUseCase.execute(
        boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaLikersFromLocal.isRight() && mediaLikersFromLocal.getOrElse(() => null) != null) {
      mediaLikersList = mediaLikersFromLocal.getOrElse(() => null)!;
      emit(MediaLikersSuccess(mediaLikers: mediaLikersList, pageKey: 0));

      // group by user id
      return await getMostLikesFromMediaLikes(mediaLikersList, pageKey, pageSize, reverse);
    }

    return null;
  }

  // get users liked media but didn't follow you
  Future<List<MediaLikers>?> getLikesUsersButNotFollow(
      {required String boxKey, required int pageKey, required int pageSize, String? searchTerm}) async {
    emit(MediaLikersLoading());
    List<MediaLiker> mediaLikerList = [];
    List<MediaLikers> mediaLikersList = [];

    // get media likers from local
    final mediaLikersFromLocal = getMediaLikersFromLocalUseCase.execute(
        boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaLikersFromLocal.isRight() && mediaLikersFromLocal.getOrElse(() => null) != null) {
      mediaLikerList = mediaLikersFromLocal.getOrElse(() => null)!;
      // delete media likers that follow you
      mediaLikerList = await deleteMediaLikersThatFollowYou(mediaLikerList);

      // group by user id
      mediaLikersList = await getMostLikesFromMediaLikes(mediaLikerList, pageKey, pageSize, false);

      // sort by likesCount
      mediaLikersList.sort((a, b) => b.likesCount.compareTo(a.likesCount));

      // paginate
      int? startKey;
      int? endKey;
      startKey = pageKey;
      endKey = startKey + pageSize;
      if (endKey > mediaLikersList.length - 1) {
        endKey = mediaLikersList.length;
      }
      mediaLikersList = mediaLikersList.sublist(startKey, endKey);
      emit(MediaLikersSuccess(mediaLikers: mediaLikerList, pageKey: 0));
      return mediaLikersList;
    }

    return null;
  }

  Future<List<MediaLikers>> getMostLikesFromMediaLikes(
      List<MediaLiker> mediaLikersList, int pageKey, int pageSize, bool reverse) async {
    // group by user id
    Map<String, List<MediaLiker>> mediaLikersMap = {};
    for (var mediaLiker in mediaLikersList) {
      if (mediaLikersMap.containsKey(mediaLiker.user.igUserId.toString())) {
        mediaLikersMap[mediaLiker.user.igUserId.toString()]!.add(mediaLiker);
      } else {
        mediaLikersMap[mediaLiker.user.igUserId.toString()] = [mediaLiker];
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

    // format MedialLiker List to MediaLikers
    List<MediaLikers> mediaLikers = [];
    mediaLikersMap.forEach((key, value) {
      // check if user is following me
      bool following = false;
      bool followedBy = false;
      if (followersList.indexWhere((element) => element.igUserId == int.parse(key)) != -1) {
        followedBy = true;
      }
      if (followingList.indexWhere((element) => element.igUserId == int.parse(key)) != -1) {
        following = true;
      }
      mediaLikers.add(MediaLikersModel.fromMediaLiker(value, key, followedBy, following).toEntity());
    });

    // sort by likesCount
    if (reverse) {
      mediaLikers.sort((a, b) => a.likesCount.compareTo(b.likesCount));
    } else {
      mediaLikers.sort((a, b) => b.likesCount.compareTo(a.likesCount));
    }

    // paginate
    int? startKey;
    int? endKey;
    startKey = pageKey;
    endKey = startKey + pageSize;
    if (endKey > mediaLikers.length - 1) {
      endKey = mediaLikers.length;
    }
    mediaLikers = mediaLikers.sublist(startKey, endKey);

    return mediaLikers;
  }

  // get users with most likes and comments from local
  Future<List<LikesAndComments>?> getWhoAdmiresYou(
      {required String boxKey, required int pageKey, required int pageSize, String? searchTerm}) async {
    emit(MediaLikersLoading());
    List<LikesAndComments> mostLikesAndComments = [];

    final failureOrWhoAdmiresYouListFromLocal = await getWhoAdmiresYouFromLocalUseCase.execute(
        boxKey: LikesAndComments.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
    if (failureOrWhoAdmiresYouListFromLocal.isRight() && (failureOrWhoAdmiresYouListFromLocal as Right).value != null) {
      mostLikesAndComments = (failureOrWhoAdmiresYouListFromLocal as Right).value;
    }

    return mostLikesAndComments;
  }

  Future<User> getCurrentUser() async {
    late User currentUser;
    // get user info
    final failureOrCurrentUser = await getUser.execute();
    if (failureOrCurrentUser.isLeft()) {
      emit(const MediaLikersFailure(message: 'Failed to get user info'));
    } else {
      currentUser = (failureOrCurrentUser as Right).value;
    }
    return currentUser;
  }

  Future<List<MediaLiker>> deleteMediaLikersThatFollowYou(List<MediaLiker> mediaLikersList) async {
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
    const nextUpdateInMinutes = 60 * 2;

    IgDataUpdate igDataUpdate = IgDataUpdate.create(
      dataName: dataName,
      nextUpdateInMinutes: nextUpdateInMinutes,
    );
    await saveIgDataUpdateUseCase.execute(igDataUpdate: igDataUpdate);
  }

  List<MediaLiker> _getMedialLikersFromLocal({required int pageKey, required int pageSize, String? searchTerm}) {
    List<MediaLiker> mediaLikersList = [];
    // get media likers from local
    final mediaLikersFromLocal = getMediaLikersFromLocalUseCase.execute(
        boxKey: MediaLiker.boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);

    if (mediaLikersFromLocal.isRight() && mediaLikersFromLocal.getOrElse(() => null) != null) {
      mediaLikersList = mediaLikersFromLocal.getOrElse(() => null)!;
      emit(MediaLikersSuccess(mediaLikers: mediaLikersList, pageKey: 0));
      return mediaLikersList;
    }
    return [];
  }
}
