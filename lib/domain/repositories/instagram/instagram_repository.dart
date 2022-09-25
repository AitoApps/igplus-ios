import 'package:dartz/dartz.dart';
import 'package:igplus_ios/domain/entities/stories_user.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:igplus_ios/domain/entities/ig_headers.dart';
import 'package:igplus_ios/domain/entities/media.dart';

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
  Future<Either<Failure, List<Story>>> getStories({
    required String userId,
    required IgHeaders igHeaders,
  });

  // follow user
  Future<Either<Failure, bool>> followUser({
    required int userId,
    required IgHeaders igHeaders,
  });

  // unfollow user
  Future<Either<Failure, bool>> unfollowUser({
    required int userId,
    required IgHeaders igHeaders,
  });

  // besties friends list
  Future<Either<Failure, List<Media>>> getUserFeed({required String userId, required IgHeaders igHeaders});
}
