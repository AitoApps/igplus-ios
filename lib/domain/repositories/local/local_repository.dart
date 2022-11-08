import 'package:dartz/dartz.dart';
import 'package:igplus_ios/data/failure.dart';
import 'package:igplus_ios/domain/entities/account_info.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:igplus_ios/domain/entities/likes_and_comments.dart';
import 'package:igplus_ios/domain/entities/media.dart';
import 'package:igplus_ios/domain/entities/media_commenter.dart';
import 'package:igplus_ios/domain/entities/media_liker.dart';
import 'package:igplus_ios/domain/entities/report.dart';
import 'package:igplus_ios/domain/entities/stories_user.dart';
import 'package:igplus_ios/domain/entities/story.dart';
import 'package:igplus_ios/domain/entities/story_viewer.dart';

abstract class LocalRepository {
  // report
  Either<Failure, Report?> getCachedReport();
  Future<void> cacheReport({required Report report});

  // friends
  Either<Failure, List<Friend>?> getCachedFriendsList({
    required String boxKey,
    int? pageKey,
    int? pageSize,
    String? searchTerm,
  });
  Future<void> cacheFriendsList({
    required List<Friend> friendsList,
    required String boxKey,
  });
  Either<Failure, int> getNumberOfFriendsInBox({required String boxKey});

  // Media
  Either<Failure, List<Media>?> getCachedMediaList({
    required String boxKey,
    int? pageKey,
    int? pageSize,
    String? searchTerm,
    String? type,
  });
  Future<void> cacheMediaList({
    required List<Media> mediaList,
    required String boxKey,
  });

  // Account info
  Either<Failure, AccountInfo?> getCachedAccountInfo();
  Future<void> cacheAccountInfo({required AccountInfo accountInfo});

  // stories list
  Either<Failure, List<Story>?> getCachedStoriesList({
    required String boxKey,
    required int pageKey,
    required int pageSize,
    String? searchTerm,
    String? type,
    required String ownerId,
  });
  Future<void> cacheStoriesList({
    required List<Story> storiesList,
    required String boxKey,
    required String ownerId,
  });

  // stories users list
  Either<Failure, List<StoriesUser>?> getCachedStoriesUsersList({required String boxKey});
  Future<void> cacheStoriesUsersList({
    required List<StoriesUser> storiesUserList,
    required String boxKey,
  });

  // story viewers list
  Future<void> cacheStoryViewersList({
    required List<StoryViewer> storiesViewersList,
    required String boxKey,
  });
  Either<Failure, List<StoryViewer>?> getCachedStoryViewersList({
    required String boxKey,
    String? mediaId,
    int? pageKey,
    int? pageSize,
    String? searchTerm,
  });

  // update story
  Future<void> updateStoryById({required String boxKey, required String mediaId, required int? viewersCount});

  // media likers
  Future<void> cacheMediaLikersList({required List<MediaLiker> mediaLikersList, required String boxKey});
  Either<Failure, List<MediaLiker>?> getCachedMediaLikersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm});

  // media commenters
  Future<void> cacheMediaCommentersList({required List<MediaCommenter> mediaCommentersList, required String boxKey});
  Either<Failure, List<MediaCommenter>?> getCachedMediaCommentersList(
      {required String boxKey, int? mediaId, int? pageKey, int? pageSize, String? searchTerm});

  // WhoAdmiresYou
  Future<void> cacheWhoAdmiresYouList({required List<LikesAndComments> whoAdmiresYouList, required String boxKey});
  Either<Failure, List<LikesAndComments>?> getCachedWhoAdmiresYouList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm});

  // clear all boxes
  Future<void> clearAllBoxes();
}
