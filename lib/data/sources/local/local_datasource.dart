import 'package:hive/hive.dart';
import 'package:igplus_ios/domain/entities/account_info.dart';
import 'package:igplus_ios/domain/entities/friend.dart';
import 'package:http/http.dart' as http;
import 'package:igplus_ios/domain/entities/media.dart';
import 'package:igplus_ios/domain/entities/report.dart';

abstract class LocalDataSource {
  Report? getCachedReport();
  Future<void> cacheReport({required Report report});
  List<Friend>? getCachedFriendsList({required String boxKey, int? pageKey, int? pageSize, String? searchTerm});
  Future<void> cacheFriendsList({required List<Friend> friendsList, required String boxKey});
  int getNumberOfFriendsInBox({required String boxKey});
  List<Media>? getCachedMediaList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm, String? type});
  Future<void> cacheMediaList({required List<Media> mediaList, required String boxKey});
  AccountInfo? getCachedAccountInfo();
  Future<void> cacheAccountInfo({required AccountInfo accountInfo});
  Future<void> clearAllBoxes();
}

class LocalDataSourceImp extends LocalDataSource {
  final http.Client client;

  LocalDataSourceImp({required this.client});

  // ----------------------->
  // report ------------------>
  // ----------------------->
  @override
  Future<void> cacheReport({required Report report}) async {
    final reportBox = Hive.box<Report>(Report.boxKey);
    try {
      await reportBox.put('report', report);
    } catch (e) {
      print(e);
    }
  }

  @override
  Report? getCachedReport() {
    try {
      final reportBox = Hive.box<Report>(Report.boxKey);
      // reportBox.deleteFromDisk();
      Report? report;
      report = reportBox.get('report');
      return report;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // ----------------------->
  // Friends ------------------>
  // ----------------------->

  @override
  List<Friend>? getCachedFriendsList({required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) {
    Box<Friend> friendsBox = Hive.box<Friend>(boxKey);
    final List<Friend> friendsList;
    int? startKey;
    int? endKey;
    if (pageKey != null && pageSize != null) {
      startKey = pageKey;
      endKey = startKey + pageSize;
      if (endKey > friendsBox.length - 1) {
        endKey = friendsBox.length;
      }
    }

    if (friendsBox.isEmpty) {
      return null;
    } else {
      if (startKey != null && endKey != null && searchTerm == null) {
        friendsList = friendsBox.values.toList().sublist(startKey, endKey);
      } else if (searchTerm != null) {
        friendsList = friendsBox.values.where((c) => c.username.toLowerCase().contains(searchTerm)).toList();
      } else {
        friendsList = friendsBox.values.toList();
      }
      return friendsList;
    }
  }

  @override
  Future<void> cacheFriendsList({required List<Friend> friendsList, required String boxKey}) async {
    Box<Friend> friendsBox = Hive.box<Friend>(boxKey);

    final List<Friend> cachedFriendsList = friendsBox.values.toList();
    final List<Friend> newFriendsListToAdd;
    // new friends list
    if (boxKey != Friend.followersBoxKey && boxKey != Friend.followingsBoxKey) {
      // keep only new friends in the list
      final List<Friend> friendsToKeep = cachedFriendsList
          .where((friend) => friend.createdOn.isAfter(DateTime.now().subtract(const Duration(days: 1))))
          .toList();
      await friendsBox.clear();
      newFriendsListToAdd = [
        ...friendsList
            .where((friend) => friendsToKeep.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
            .toList(),
        ...friendsToKeep
      ];
    } else {
      newFriendsListToAdd = friendsList
          .where((friend) => cachedFriendsList.indexWhere((element) => friend.igUserId == element.igUserId) == -1)
          .toList();
    }

    try {
      for (var e in newFriendsListToAdd) {
        friendsBox.add(e);
      }
    } catch (e) {
      print(e);
    }
  }

  // get number of friends in the box
  @override
  int getNumberOfFriendsInBox({required String boxKey}) {
    Box<Friend> friendsBox = Hive.box<Friend>(boxKey);
    return friendsBox.length;
  }

  // ----------------------->
  // Media ------------------>
  // ----------------------->

  // save media to local storage
  @override
  Future<void> cacheMediaList({required List<Media> mediaList, required String boxKey}) async {
    Box<Media> mediaBox = Hive.box<Media>(boxKey);

    final List<Media> cachedMediaList = mediaBox.values.toList();
    final List<Media> newMediaListToAdd;

    // new media list to add to the box
    newMediaListToAdd =
        mediaList.where((media) => cachedMediaList.indexWhere((element) => media.code == element.code) == -1).toList();

    try {
      for (var e in newMediaListToAdd) {
        mediaBox.add(e);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  List<Media>? getCachedMediaList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm, String? type}) {
    Box<Media> mediaBox = Hive.box<Media>(boxKey);
    // mediaBox.deleteFromDisk();
    List<Media> mediaList;
    int? startKey;
    int? endKey;
    if (pageKey != null && pageSize != null) {
      startKey = pageKey;
      endKey = startKey + pageSize;
      if (endKey > mediaBox.length - 1) {
        endKey = mediaBox.length;
      }
    }

    if (mediaBox.isEmpty) {
      return null;
    } else {
      if (startKey != null && endKey != null) {
        mediaList = mediaBox.values.toList().sublist(startKey, endKey);

        //  search keyword
        if (searchTerm != null) {
          mediaList = mediaBox.values.where((c) => c.text.toLowerCase().contains(searchTerm)).toList();
        }

        // order by
        if (type != null) {
          if (type == 'mostPopularMedia') {
            mediaList.sort((a, b) => (b.likeCount + b.commentsCount).compareTo(a.likeCount + a.commentsCount));
          } else if (type == 'mostLikedMedia') {
            mediaList.sort((a, b) => b.likeCount.compareTo(a.likeCount));
          } else if (type == 'mostCommentedMedia') {
            mediaList.sort((a, b) => b.commentsCount.compareTo(a.commentsCount));
          } else if (type == 'mostViewedMedia') {
            mediaList = mediaList.where((element) => element.mediaType == 2).toList();
            mediaList.sort((a, b) => b.viewCount.compareTo(a.viewCount));
          }
        }
      } else {
        mediaList = mediaBox.values.toList();
      }
      return mediaList;
    }
  }

  // ----------------------->
  // Account Info ------------------>
  // ----------------------->

  @override
  Future<void> cacheAccountInfo({required AccountInfo accountInfo}) async {
    final accountInfoBox = Hive.box<AccountInfo>(AccountInfo.boxKey);
    try {
      accountInfoBox.put('accountInfo', accountInfo);
    } catch (e) {
      print(e);
    }
  }

  @override
  AccountInfo? getCachedAccountInfo() {
    final accountInfoBox = Hive.box<AccountInfo>(AccountInfo.boxKey);
    if (accountInfoBox.isEmpty) {
      return null;
    } else {
      return accountInfoBox.get('accountInfo');
    }
  }

  // ----------------------->
  // Clear all boxes ------------------>
  // ----------------------->
  @override
  Future<void> clearAllBoxes() async {
    await Hive.deleteBoxFromDisk(Media.boxKey);
    await Hive.deleteBoxFromDisk(Report.boxKey);
    await Hive.deleteBoxFromDisk(Friend.followersBoxKey);
    await Hive.deleteBoxFromDisk(Friend.followingsBoxKey);
    await Hive.deleteBoxFromDisk(Friend.newFollowersBoxKey);
    await Hive.deleteBoxFromDisk(Friend.lostFollowersBoxKey);
    await Hive.deleteBoxFromDisk(Friend.whoAdmiresYouBoxKey);
    await Hive.deleteBoxFromDisk(Friend.notFollowingBackBoxKey);
    await Hive.deleteBoxFromDisk(Friend.youDontFollowBackBoxKey);
    await Hive.deleteBoxFromDisk(Friend.mutualFollowingsBoxKey);
    await Hive.deleteBoxFromDisk(Friend.youHaveUnfollowedBoxKey);
    await Hive.deleteBoxFromDisk(Friend.newStoryViewersBoxKey);

    // Hive.box<Media>(Media.boxKey);
    // Hive.box<Report>(Report.boxKey);
    // Hive.box<Friend>(Friend.followersBoxKey);
    // Hive.box<Friend>(Friend.followingsBoxKey);
    // Hive.box<Friend>(Friend.newFollowersBoxKey);
    // Hive.box<Friend>(Friend.lostFollowersBoxKey);
    // Hive.box<Friend>(Friend.whoAdmiresYouBoxKey);
    // Hive.box<Friend>(Friend.notFollowingBackBoxKey);
    // Hive.box<Friend>(Friend.youDontFollowBackBoxKey);
    // Hive.box<Friend>(Friend.mutualFollowingsBoxKey);
    // Hive.box<Friend>(Friend.youHaveUnfollowedBoxKey);
    // Hive.box<Friend>(Friend.newStoryViewersBoxKey);
  }
}
