import 'package:igshark/data/failure.dart';
import 'package:igshark/data/models/likes_and_comments_model.dart';
import 'package:igshark/data/models/media_commenters_model.dart';
import 'package:igshark/data/models/media_likers_model.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_commenters.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/media_likers.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_from_local_use_case.dart';

class GetWhoAdmiresYouFromLocalUseCase {
  final LocalRepository localRepository;
  final GetMediaLikersFromLocalUseCase getMediaLikersFromLocalUseCase;
  final GetMediaCommentersFromLocalUseCase getMediaCommentersFromLocalUseCase;
  final GetFriendsFromLocalUseCase getFriendsFromLocalUseCase;
  GetWhoAdmiresYouFromLocalUseCase({
    required this.localRepository,
    required this.getMediaLikersFromLocalUseCase,
    required this.getMediaCommentersFromLocalUseCase,
    required this.getFriendsFromLocalUseCase,
  });

  Future<Either<Failure, List<LikesAndComments>?>> execute(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) async {
    try {
      final admirers = localRepository.getCachedWhoAdmiresYouList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
      if (admirers.isLeft()) {
        return const Left(InvalidParamsFailure('No media likers found'));
      } else {
        List<LikesAndComments> whoAdmiresYouList = await getWhoAdmiresYou();
        // save whoAdmiresYouList to local
        await localRepository.cacheWhoAdmiresYouList(
            whoAdmiresYouList: whoAdmiresYouList, boxKey: LikesAndComments.boxKey);
        // get friends who you admire
        whoAdmiresYouList =
            whoAdmiresYouList.where((element) => element.total > 2 && element.followedBy == true).toList();

        return admirers;
      }
    } catch (e) {
      return const Left(InvalidParamsFailure("GetMediaLikersFromLocalUseCase catch"));
    }
  }

  Future<List<LikesAndComments>> getWhoAdmiresYou() async {
    // get friends who admires you

    List<LikesAndComments> whoAdmiresYouFriendsList = [];
    List<MediaLiker> mediaLikers = [];

    List<MediaCommenter> mediaCommenters = [];

    // get media likers from local
    final mediaLikersFromLocal =
        getMediaLikersFromLocalUseCase.execute(boxKey: MediaLiker.boxKey, pageKey: 0, pageSize: 15, searchTerm: "");
    if (mediaLikersFromLocal.isRight() && (mediaLikersFromLocal as Right).value != null) {
      mediaLikers = (mediaLikersFromLocal as Right).value;
    }

    // media commenters from local
    final mediaCommentersFromLocal = getMediaCommentersFromLocalUseCase.execute(
        boxKey: MediaCommenter.boxKey, pageKey: 0, pageSize: 15, searchTerm: "");
    if (mediaCommentersFromLocal.isRight() && (mediaCommentersFromLocal as Right).value != null) {
      mediaCommenters = (mediaCommentersFromLocal as Right).value;
    }

    // get most likes and comments users (admirers)
    whoAdmiresYouFriendsList =
        await getMostLikesAndCommentsFromMediaLikesAndComments(mediaLikers, mediaCommenters, 0, 20);

    return whoAdmiresYouFriendsList;
  }

  Future<List<LikesAndComments>> getMostLikesAndCommentsFromMediaLikesAndComments(
      List<MediaLiker> mediaLikersList, List<MediaCommenter> mediaCommentersList, int pageKey, int pageSize) async {
    List<LikesAndComments> totalLikesAndComments = [];

    // group likers by user id
    Map<String, List<MediaLiker>> mediaLikersMap = {};
    for (var mediaLiker in mediaLikersList) {
      if (mediaLikersMap.containsKey(mediaLiker.user.igUserId.toString())) {
        mediaLikersMap[mediaLiker.user.igUserId.toString()]!.add(mediaLiker);
      } else {
        mediaLikersMap[mediaLiker.user.igUserId.toString()] = [mediaLiker];
      }
    }

    // group commenters by user id
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

    for (var mediaLiker in mediaLikers) {
      bool isCommenter = false;
      for (var mediaCommenter in mediaCommenters) {
        if (mediaLiker.mediaLikerList.first.user.igUserId == mediaCommenter.mediaCommenterList.first.user.igUserId) {
          totalLikesAndComments
              .add(LikesAndCommentsModel.fromMediaLikersAndCommenters(mediaLiker, mediaCommenter).toEntity());
          isCommenter = true;
          break;
        }
      }
      if (!isCommenter) {
        totalLikesAndComments.add(LikesAndCommentsModel.fromMediaLikersAndCommenters(mediaLiker, null).toEntity());
      }
    }

    totalLikesAndComments.sort((a, b) => b.total.compareTo(a.total));

    return totalLikesAndComments;
  }
}
