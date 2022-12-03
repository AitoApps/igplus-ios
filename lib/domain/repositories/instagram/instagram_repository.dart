import 'package:dartz/dartz.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/ig_headers.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/story_viewer.dart';

import '../../../data/failure.dart';
import '../../entities/account_info.dart';
import '../../entities/story.dart';

abstract class InstagramRepository {
  Future<Either<Failure, AccountInfo>> getAccountInfo({
    String? username,
    String? igUserId,
    required IgHeaders igHeaders,
  });
  Future<Either<Failure, List<Friend>>> getFollowings({
    required String igUserId,
    required IgHeaders igHeaders,
    String? maxIdString,
  });
  Future<Either<Failure, List<Friend>>> getFollowers({
    required String igUserId,
    required IgHeaders igHeaders,
    String? maxIdString,
    required List<Friend> cachedFollowersList,
    required int newFollowersNumber,
  });

  // get user stories
  Future<Either<Failure, List<StoriesUser>>> getUserStories({
    required IgHeaders igHeaders,
  });

  // getstories
  Future<Either<Failure, List<Story?>>> getStories({
    required String userId,
    required IgHeaders igHeaders,
  });

  // follow user
  Future<Either<Failure, bool>> followUser({
    required String userId,
    required IgHeaders igHeaders,
  });

  // unfollow user
  Future<Either<Failure, bool>> unfollowUser({
    required String userId,
    required IgHeaders igHeaders,
  });

  // user feed media list
  Future<Either<Failure, List<Media>>> getUserFeed({required String userId, required IgHeaders igHeaders});

  // story viewers list
  Future<Either<Failure, List<StoryViewer>>> getStoryViewers({required String mediaId, required IgHeaders igHeaders});

  // get media likers
  Future<Either<Failure, List<MediaLiker>>> getMediaLikers({required String mediaId, required IgHeaders igHeaders});

  // get media commenters list
  Future<Either<Failure, List<MediaCommenter>>> getMediaCommenters(
      {required String mediaId, required IgHeaders igHeaders});
}
