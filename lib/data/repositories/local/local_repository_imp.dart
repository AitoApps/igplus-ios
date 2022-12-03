import 'package:dartz/dartz.dart';
import 'package:igshark/data/failure.dart';
import 'package:igshark/data/sources/local/local_datasource.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/report.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/entities/story.dart';
import 'package:igshark/domain/entities/story_viewer.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';

class LocalRepositoryImpl implements LocalRepository {
  final LocalDataSource localDataSource;
  LocalRepositoryImpl({
    required this.localDataSource,
  });

  // report
  @override
  Future<void> cacheReport({required Report report}) async {
    await localDataSource.cacheReport(report: report);
  }

  @override
  Either<Failure, Report?> getCachedReport() {
    try {
      final report = localDataSource.getCachedReport();
      if (report == null) {
        return const Left(InvalidParamsFailure('No report found'));
      } else {
        return Right(report);
      }
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedReport catch"));
    }
  }

  // Friends
  @override
  Future<void> cacheFriendsList({required List<Friend> friendsList, required String boxKey}) async {
    await localDataSource.cacheFriendsList(
      friendsList: friendsList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<Friend>?> getCachedFriendsList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final List<Friend>? cachedFriendsList = localDataSource.getCachedFriendsList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
      return Right(cachedFriendsList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedFriendsList catch"));
    }
  }

  // add & remove friend
  @override
  Future<void> addFriend({required Friend friend, required String boxKey}) async {
    await localDataSource.addFriend(friend: friend, boxKey: boxKey);
  }

  @override
  Future<void> removeFriend({required Friend friend, required String boxKey}) async {
    await localDataSource.removeFriend(friend: friend, boxKey: boxKey);
  }

  // get number of friends in box
  @override
  Either<Failure, int> getNumberOfFriendsInBox({required String boxKey}) {
    try {
      final int numberOfFriends = localDataSource.getNumberOfFriendsInBox(boxKey: boxKey);
      return Right(numberOfFriends);
    } catch (e) {
      return const Left(InvalidParamsFailure("getNumberOfFriendsInBox catch"));
    }
  }

  // Media
  @override
  Future<void> cacheMediaList({required List<Media> mediaList, required String boxKey}) async {
    await localDataSource.cacheMediaList(
      mediaList: mediaList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<Media>?> getCachedMediaList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm, String? type}) {
    try {
      final List<Media>? cachedMediaList = localDataSource.getCachedMediaList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm, type: type);
      return Right(cachedMediaList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedMediaList catch"));
    }
  }

  // account info
  @override
  Future<void> cacheAccountInfo({required AccountInfo accountInfo}) async {
    await localDataSource.cacheAccountInfo(accountInfo: accountInfo);
  }

  @override
  Either<Failure, AccountInfo?> getCachedAccountInfo() {
    try {
      final accountInfo = localDataSource.getCachedAccountInfo();
      if (accountInfo == null) {
        return const Left(InvalidParamsFailure('No accountInfo found'));
      } else {
        return Right(accountInfo);
      }
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedAccountInfo catch"));
    }
  }

  // stories
  @override
  Future<void> cacheStoriesList(
      {required List<Story> storiesList, required String boxKey, required String ownerId}) async {
    await localDataSource.cacheStoriesList(
      storiesList: storiesList,
      boxKey: boxKey,
      ownerId: ownerId,
    );
  }

  @override
  Either<Failure, List<Story>?> getCachedStoriesList({
    required String boxKey,
    required int pageKey,
    required int pageSize,
    String? searchTerm,
    String? type,
    required String ownerId,
  }) {
    try {
      final List<Story>? cachedStoriesList = localDataSource.getCachedStoriesList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm, type: type, ownerId: ownerId);
      return Right(cachedStoriesList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedStoriesList catch"));
    }
  }

  // stories users
  @override
  Future<void> cacheStoriesUsersList({required List<StoriesUser> storiesUserList, required String boxKey}) async {
    await localDataSource.cacheStoriesUsersList(
      storiesUserList: storiesUserList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<StoriesUser>?> getCachedStoriesUsersList({required String boxKey}) {
    try {
      final List<StoriesUser>? cachedStoriesList = localDataSource.getCachedStoriesUsersList(boxKey: boxKey);
      return Right(cachedStoriesList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedStoriesUserList catch"));
    }
  }

  // stories viewers
  Future<void> cacheStoryViewersList({required List<StoryViewer> storiesViewersList, required String boxKey}) async {
    await localDataSource.cacheStoryViewersList(
      storiesViewersList: storiesViewersList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<StoryViewer>?> getCachedStoryViewersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final List<StoryViewer>? cachedStoriesViewersList = localDataSource.getCachedStoryViewersList(
        boxKey: boxKey,
        mediaId: mediaId,
        pageKey: pageKey,
        pageSize: pageSize,
        searchTerm: searchTerm,
      );
      return Right(cachedStoriesViewersList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedStoriesUserList catch"));
    }
  }

  // update story viewers count
  @override
  Future<void> updateStoryById({required String boxKey, required String mediaId, required int? viewersCount}) async {
    await localDataSource.updateStoryById(
      boxKey: boxKey,
      mediaId: mediaId,
      viewersCount: viewersCount,
    );
  }

  // Media likers
  @override
  Future<void> cacheMediaLikersList({required List<MediaLiker> mediaLikersList, required String boxKey}) async {
    await localDataSource.cacheMediaLikersList(
      mediaLikersList: mediaLikersList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<MediaLiker>?> getCachedMediaLikersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final List<MediaLiker>? cachedMediaLikersList = localDataSource.getCachedMediaLikersList(
        boxKey: boxKey,
        mediaId: mediaId,
        pageKey: pageKey,
        pageSize: pageSize,
        searchTerm: searchTerm,
      );
      return Right(cachedMediaLikersList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedMediaLikersList catch"));
    }
  }

  // Media commenters list
  @override
  Future<void> cacheMediaCommentersList(
      {required List<MediaCommenter> mediaCommentersList, required String boxKey}) async {
    await localDataSource.cacheMediaCommentersList(
      mediaCommentersList: mediaCommentersList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<MediaCommenter>?> getCachedMediaCommentersList(
      {required String boxKey, int? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final List<MediaCommenter>? cachedMediaCommentersList = localDataSource.getCachedMediaCommentersList(
        boxKey: boxKey,
        mediaId: mediaId,
        pageKey: pageKey,
        pageSize: pageSize,
        searchTerm: searchTerm,
      );
      return Right(cachedMediaCommentersList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedMediaCommentersList catch"));
    }
  }

  // WhoAdmiresYou list
  @override
  Future<void> cacheWhoAdmiresYouList(
      {required List<LikesAndComments> whoAdmiresYouList, required String boxKey}) async {
    await localDataSource.cacheWhoAdmiresYouList(
      whoAdmiresYouList: whoAdmiresYouList,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, List<LikesAndComments>?> getCachedWhoAdmiresYouList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) {
    try {
      final List<LikesAndComments>? cachedWhoAdmiresYouList = localDataSource.getCachedWhoAdmiresYouList(
          boxKey: boxKey, pageKey: pageKey, pageSize: pageSize, searchTerm: searchTerm);
      return Right(cachedWhoAdmiresYouList);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedWhoAdmiresYouList catch"));
    }
  }

  // IgDataUpdate
  @override
  Future<void> cacheIgDataUpdate({required IgDataUpdate igDataUpdate, required String boxKey}) async {
    await localDataSource.cacheIgDataUpdate(
      igDataUpdate: igDataUpdate,
      boxKey: boxKey,
    );
  }

  @override
  Either<Failure, IgDataUpdate?> getCachedIgDataUpdate({required String boxKey, required String dataName}) {
    try {
      final IgDataUpdate? cachedIgDataUpdate =
          localDataSource.getCachedIgDataUpdate(boxKey: boxKey, dataName: dataName);
      return Right(cachedIgDataUpdate);
    } catch (e) {
      return const Left(InvalidParamsFailure("getCachedIgDataUpdate catch"));
    }
  }

  // clear all boxes
  @override
  Future<void> clearAllBoxes() async {
    await localDataSource.clearAllBoxes();
  }
}
