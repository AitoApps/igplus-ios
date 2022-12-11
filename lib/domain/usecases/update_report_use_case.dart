import 'package:dartz/dartz.dart';
import 'package:igshark/data/models/likes_and_comments_model.dart';
import 'package:igshark/data/models/media_commenters_model.dart';
import 'package:igshark/data/models/media_likers_model.dart';

import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_commenters.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/media_likers.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_from_local_use_case.dart';
import 'package:intl/intl.dart';
import '../../data/failure.dart';
import '../entities/report.dart';
import '../entities/user.dart';
import '../repositories/instagram/instagram_repository.dart';

class UpdateReportUseCase {
  final InstagramRepository instagramRepository;
  final LocalRepository localRepository;
  final GetMediaLikersFromLocalUseCase getMediaLikersFromLocalUseCase;
  final GetMediaCommentersFromLocalUseCase getMediaCommentersFromLocalUseCase;
  final GetFriendsFromLocalUseCase getFriendsFromLocalUseCase;

  UpdateReportUseCase({
    required this.instagramRepository,
    required this.localRepository,
    required this.getMediaLikersFromLocalUseCase,
    required this.getMediaCommentersFromLocalUseCase,
    required this.getFriendsFromLocalUseCase,
  });

  Future<Either<Failure, Report>> execute({required User currentUser, required AccountInfo accountInfo}) async {
    // get old data from local ------------->
    final List<Friend>? cachedFollowers;
    final List<Friend>? cachedFollowings;
    final Report? cachedReport;

    // get Cached followers list from local
    final failureOrFollowersListFromLocal = localRepository.getCachedFriendsList(boxKey: Friend.followersBoxKey);
    if (failureOrFollowersListFromLocal.isRight()) {
      cachedFollowers = (failureOrFollowersListFromLocal as Right).value;
    } else {
      cachedFollowers = null;
    }

    // get Cached followings list from local
    final failureOrFollowingsListFromLocal = localRepository.getCachedFriendsList(boxKey: Friend.followingsBoxKey);
    if (failureOrFollowingsListFromLocal.isRight()) {
      cachedFollowings = (failureOrFollowingsListFromLocal as Right).value;
    } else {
      cachedFollowings = null;
    }

    // get cached report from local
    final failureOrReportFromLocal = localRepository.getCachedReport();
    if (failureOrReportFromLocal.isRight()) {
      cachedReport = (failureOrReportFromLocal as Right).value;
    } else {
      cachedReport = null;
    }

    // get followers list from instagram ----->
    final Either<Failure, List<Friend>> followersEither = await instagramRepository.getFollowers(
      igUserId: accountInfo.igUserId,
      igHeaders: currentUser.igHeaders,
      maxIdString: null,
      cachedFollowersList: cachedFollowers ?? [],
      newFollowersNumber: accountInfo.followers,
    );
    if (followersEither.isLeft()) {
      return Left((followersEither as Left).value);
    }
    final List<Friend> followers = (followersEither as Right).value;

    // get followings list from instagram ----->
    final Either<Failure, List<Friend>> followingsEither =
        await instagramRepository.getFollowings(igUserId: accountInfo.igUserId, igHeaders: currentUser.igHeaders);
    if (followingsEither.isLeft()) {
      return Left((followingsEither as Left).value);
    }
    final List<Friend> followings = (followingsEither as Right).value;

    // save followings to local
    await localRepository.cacheFriendsList(friendsList: followings, boxKey: Friend.followingsBoxKey);
    // save followers to local
    await localRepository.cacheFriendsList(friendsList: followers, boxKey: Friend.followersBoxKey);

    // list of friends that are not in the followers list
    final List<Friend> notFollowingBack = followings
        .where((friend) => followers.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
        .toList();

    // save notFollowingBack to local
    await localRepository.cacheFriendsList(friendsList: notFollowingBack, boxKey: Friend.notFollowingBackBoxKey);

    // list of friends that are not in the followings list
    final List<Friend> youDontFollowBack = followers
        .where((friend) => followings.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
        .toList();

    // save youDontFollowBackBoxKey to local
    await localRepository.cacheFriendsList(friendsList: youDontFollowBack, boxKey: Friend.youDontFollowBackBoxKey);

    // list of friends that are in both lists
    final List<Friend> mutualFollowings = followings
        .where((friend) => followers.indexWhere((element) => friend.igUserId == element.igUserId) > -1)
        .toList();
    // save mutualFollowings to local
    await localRepository.cacheFriendsList(friendsList: mutualFollowings, boxKey: Friend.mutualFollowingsBoxKey);

    // new followers and lost followers
    List<Friend> newFollowersList = [];
    List<Friend> lostFollowersList = [];
    if (cachedFollowers != null) {
      // new followers
      newFollowersList = followers
          .where((friend) => cachedFollowers!.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
          .toList();
      // lost followers
      lostFollowersList = cachedFollowers
          .where((friend) => followers.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
          .toList();
      // save new followers to local
      await localRepository.cacheFriendsList(friendsList: newFollowersList, boxKey: Friend.newFollowersBoxKey);
      // save lost followers to local
      await localRepository.cacheFriendsList(friendsList: lostFollowersList, boxKey: Friend.lostFollowersBoxKey);
    }

    // you have unfollowed
    List<Friend> youHaveUnfollowedList = [];
    if (cachedFollowings != null) {
      youHaveUnfollowedList = cachedFollowings
          .where((friend) => followings.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
          .toList();
      // save you have unfollowed to local
      await localRepository.cacheFriendsList(
          friendsList: youHaveUnfollowedList, boxKey: Friend.youHaveUnfollowedBoxKey);
    }

    // initialize chart data
    String today =
        DateFormat('M/d/yy').format(DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch));
    late final List<ChartData> followersChartData;
    late final List<ChartData> followingsChartData;
    late final List<ChartData> newFollowersChartData;
    late final List<ChartData> lostFollowersChartData;

    // if there is no cached report, initialize chart data else puch new data ------->
    // followers chart data
    if (cachedReport == null || cachedReport.followersChartData.isEmpty) {
      followersChartData = [ChartData(date: today, value: accountInfo.followers)];
    } else {
      followersChartData = cachedReport.followersChartData;
      if (followersChartData.last.date != today) {
        followersChartData.add(ChartData(date: today, value: accountInfo.followers));
      } else {
        followersChartData.last.value = accountInfo.followers;
      }
    }
    // followings chart data
    if (cachedReport == null || cachedReport.followingsChartData.isEmpty) {
      followingsChartData = [ChartData(date: today, value: accountInfo.followings)];
    } else {
      followingsChartData = cachedReport.followingsChartData;
      if (followingsChartData.last.date != today) {
        followingsChartData.add(ChartData(date: today, value: accountInfo.followings));
      } else {
        followingsChartData.last.value = accountInfo.followings;
      }
    }
    // new followers chart data
    if (cachedReport == null || cachedReport.newFollowersChartData.isEmpty) {
      newFollowersChartData = [ChartData(date: today, value: 0)];
    } else {
      newFollowersChartData = cachedReport.newFollowersChartData;
      if (newFollowersChartData.last.date != today) {
        newFollowersChartData.add(ChartData(date: today, value: 0));
      } else {
        newFollowersChartData.last.value = 0;
      }
    }
    // lost followers chart data
    if (cachedReport == null || cachedReport.lostFollowersChartData.isEmpty) {
      lostFollowersChartData = [ChartData(date: today, value: 0)];
    } else {
      lostFollowersChartData = cachedReport.lostFollowersChartData;
      if (lostFollowersChartData.last.date != today) {
        lostFollowersChartData.add(ChartData(date: today, value: 0));
      } else {
        lostFollowersChartData.last.value = 0;
      }
    }

    // Get Cycle Stats from local and calculate changes ---->
    // get number of newFollowers
    int newFollowersCycle = 0;
    final Either<Failure, int> newFollowersCycleEither =
        localRepository.getNumberOfFriendsInBox(boxKey: Friend.newFollowersBoxKey);
    if (newFollowersCycleEither.isRight()) {
      newFollowersCycle = (newFollowersCycleEither as Right).value;
    }
    // get number of lostFollowers
    int lostFollowersCycle = 0;
    final Either<Failure, int> lostFollowersCycleEither =
        localRepository.getNumberOfFriendsInBox(boxKey: Friend.lostFollowersBoxKey);
    if (lostFollowersCycleEither.isRight()) {
      lostFollowersCycle = (lostFollowersCycleEither as Right).value;
    }
    // get number of youHaveUnfollowed
    int youHaveUnfollowedCycle = 0;
    final Either<Failure, int> youHaveUnfollowedCycleEither =
        localRepository.getNumberOfFriendsInBox(boxKey: Friend.youHaveUnfollowedBoxKey);
    if (youHaveUnfollowedCycleEither.isRight()) {
      youHaveUnfollowedCycle = (youHaveUnfollowedCycleEither as Right).value;
    }

    // calculate changes
    final int notFollowingBackChanges;
    final int mutualFollowingsChanges;
    final int youDontFollowBackChanges;

    if (cachedReport != null) {
      // calculate not following back changes
      notFollowingBackChanges = notFollowingBack.length - cachedReport.notFollowingBackCycle;
      // calculate mutual followings changes
      mutualFollowingsChanges = mutualFollowings.length - cachedReport.mutualFollowingsCycle;
      // calculate you don't follow back changes
      youDontFollowBackChanges = youDontFollowBack.length - cachedReport.youDontFollowBackCycle;
    } else {
      notFollowingBackChanges = 0;
      mutualFollowingsChanges = 0;
      youDontFollowBackChanges = 0;
    }

    final Report report = Report(
      followers: accountInfo.followers,
      followings: accountInfo.followings,
      notFollowingBack: notFollowingBackChanges,
      youDontFollowBack: youDontFollowBackChanges,
      mutualFollowings: mutualFollowingsChanges,
      newFollowers: newFollowersList.length,
      lostFollowers: lostFollowersList.length,
      followersChartData: followersChartData,
      followingsChartData: followingsChartData,
      newFollowersChartData: newFollowersChartData,
      lostFollowersChartData: lostFollowersChartData,
      youHaveUnfollowed: youHaveUnfollowedList.length,
      newFollowersCycle: newFollowersCycle,
      lostFollowersCycle: lostFollowersCycle,
      youHaveUnfollowedCycle: youHaveUnfollowedCycle,
      notFollowingBackCycle: notFollowingBack.length,
      youDontFollowBackCycle: youDontFollowBack.length,
      mutualFollowingsCycle: mutualFollowings.length,
      whoAdmiresYou: const [],
    );

    // save report to local
    await localRepository.cacheReport(report: report);

    return Right(report);
  }
}
