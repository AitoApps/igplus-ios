import 'package:hive/hive.dart';
import 'package:igshark/domain/entities/account_info.dart';
import 'package:igshark/domain/entities/friend.dart';
import 'package:http/http.dart' as http;
import 'package:igshark/domain/entities/ig_data_update.dart';
import 'package:igshark/domain/entities/likes_and_comments.dart';
import 'package:igshark/domain/entities/media.dart';
import 'package:igshark/domain/entities/media_commenter.dart';
import 'package:igshark/domain/entities/media_liker.dart';
import 'package:igshark/domain/entities/report.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/entities/story.dart';
import 'package:igshark/domain/entities/story_viewer.dart';

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
  List<Story>? getCachedStoriesList(
      {required String boxKey,
      required int pageKey,
      required int pageSize,
      String? searchTerm,
      String? type,
      required String ownerId});
  Future<void> cacheStoriesList({
    required List<Story> storiesList,
    required String boxKey,
    required String ownerId,
  });
  // stories users
  List<StoriesUser>? getCachedStoriesUsersList({required String boxKey});
  Future<void> cacheStoriesUsersList({required List<StoriesUser> storiesUserList, required String boxKey});
  // story viewers
  Future<void> cacheStoryViewersList({required List<StoryViewer> storiesViewersList, required String boxKey});
  List<StoryViewer>? getCachedStoryViewersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm});
  Future<void> updateStoryById({required String boxKey, required String mediaId, int? viewersCount});
  Future<void> cacheMediaLikersList({required List<MediaLiker> mediaLikersList, required String boxKey});
  List<MediaLiker>? getCachedMediaLikersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm});
  Future<void> cacheMediaCommentersList({required List<MediaCommenter> mediaCommentersList, required String boxKey});
  List<MediaCommenter>? getCachedMediaCommentersList(
      {required String boxKey, int? mediaId, int? pageKey, int? pageSize, String? searchTerm});
  Future<void> cacheWhoAdmiresYouList({required List<LikesAndComments> whoAdmiresYouList, required String boxKey});
  List<LikesAndComments>? getCachedWhoAdmiresYouList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm});
  Future<void> cacheIgDataUpdate({required IgDataUpdate igDataUpdate, required String boxKey});
  IgDataUpdate? getCachedIgDataUpdate({required String boxKey, required String dataName});
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

  // add & remove friend
  @override
  Future<void> addFriend({required Friend friend, required String boxKey}) async {
    Box<Friend> friendsBox = Hive.box<Friend>(boxKey);
    try {
      friendsBox.add(friend);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> removeFriend({required String friendKey, required String boxKey}) async {
    Box<Friend> friendsBox = Hive.box<Friend>(boxKey);
    try {
      friendsBox.delete(friendKey);
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

        // search keyword
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
  // Stories ------------------>
  // ----------------------->

  // cache stories
  @override
  Future<void> cacheStoriesList(
      {required List<Story> storiesList, required String boxKey, required String ownerId}) async {
    // open box
    Box<StoriesUser> usersStorytoriesBox = Hive.box<StoriesUser>(StoriesUser.boxKey);
    // get story user to update
    final storiesUsersToUpdate = usersStorytoriesBox.values.where((element) => element.id == ownerId);
    if (storiesUsersToUpdate.isNotEmpty) {
      final StoriesUser storiesUserToUpdate = storiesUsersToUpdate.first;
      // update stories list
      storiesUserToUpdate.stories = storiesList;
      // save chages to the box
      usersStorytoriesBox.put(storiesUserToUpdate.id, storiesUserToUpdate);
    } else {
      // story not found in the box. we must add it
      // get current user id
      AccountInfo? accountInfo = getCachedAccountInfo();
      if (accountInfo != null) {
        final StoriesUser storiesUser = StoriesUser(
          id: ownerId,
          stories: storiesList,
          expiringAt: DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch,
          latestReelMedia: 0,
          seen: 0,
          owner: StoryOwner(id: ownerId, username: accountInfo.username, profilePicUrl: accountInfo.picture),
        );
        usersStorytoriesBox.put(storiesUser.id, storiesUser);
      }
    }
  }

// update number of story viewers by mediaId
  @override
  Future<void> updateStoryById({required String boxKey, required String mediaId, int? viewersCount}) async {
    // open box
    Box<StoriesUser> storiesBox = Hive.box<StoriesUser>(boxKey);
    // get storiesuser where story mediaId = mediaId
    final StoriesUser storiesUserToUpdate = storiesBox.values
        .where((element) => element.stories.indexWhere((story) => story.mediaId == mediaId) != -1)
        .first;

    // update story viewers count
    storiesUserToUpdate.stories.where((element) => element.mediaId == mediaId).first.viewersCount = viewersCount;

    // save chages to the box
    storiesBox.put(storiesUserToUpdate.id, storiesUserToUpdate);
  }

  // get stories from local storage
  @override
  List<Story>? getCachedStoriesList(
      {required String boxKey,
      String? searchTerm,
      String? type,
      int? pageKey,
      int? pageSize,
      required String ownerId}) {
    Box<StoriesUser> usersStorytoriesBox = Hive.box<StoriesUser>(StoriesUser.boxKey);

    List<Story> storiesList = usersStorytoriesBox.values.where((element) => element.id == ownerId).first.stories;
    List<Story> expiredStoriesList;
    if (storiesList.isEmpty) {
      return null;
    } else {
      // get expired stories lsit
      int expireDate = (DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch / 1000).floor();
      expiredStoriesList = storiesList.where((element) => element.takenAt < expireDate).toList();

      // remove expired stories from the list
      for (var element in expiredStoriesList) {
        storiesList.remove(element);
      }

      if (type == "mostViewedStories") {
        // remove stories with null viewers count
        storiesList = storiesList.where((element) => element.viewersCount != null).toList();
      }

      // remove stories with takenAt greater than 24 hours
      storiesList = storiesList.where((element) => element.takenAt > expireDate).toList();

      return storiesList;
    }
  }

  // ----------------------->
  // Stories Users ------------------>
  // ----------------------->

  // cache stories user
  @override
  Future<void> cacheStoriesUsersList({required List<StoriesUser> storiesUserList, required String boxKey}) async {
    Box<StoriesUser> usersStorytoriesBox = Hive.box<StoriesUser>(StoriesUser.boxKey);

    final List<StoriesUser> cachedStoriesList = usersStorytoriesBox.values.toList();
    final List<StoriesUser> newStoriesListToAdd;

    // new stories list to add to the box
    newStoriesListToAdd = storiesUserList
        .where((story) => cachedStoriesList.indexWhere((element) => story.id == element.id) == -1)
        .toList();

    try {
      for (var e in newStoriesListToAdd) {
        usersStorytoriesBox.put(e.id, e);
      }
    } catch (e) {
      print(e);
    }
  }

  // get stories from local storage
  @override
  List<StoriesUser>? getCachedStoriesUsersList({required String boxKey}) {
    Box<StoriesUser> usersStorytoriesBox = Hive.box<StoriesUser>(StoriesUser.boxKey);

    List<StoriesUser> storiesUserList;
    List<StoriesUser> expiredStoriesUserList;

    if (usersStorytoriesBox.isEmpty) {
      return null;
    } else {
      // expired storiesUser list
      int expireDate = (DateTime.now().millisecondsSinceEpoch / 1000).floor();

      expiredStoriesUserList = usersStorytoriesBox.values.where((element) => element.expiringAt < expireDate).toList();

      // remove expired storiesUser from the box
      for (var e in expiredStoriesUserList) {
        usersStorytoriesBox.delete(e.id);
      }

      // storiesUser where expiringAt > now
      storiesUserList = usersStorytoriesBox.values.where((element) => element.expiringAt >= expireDate).toList();
      return storiesUserList;
    }
  }

  // ----------------------->
  // Stories Viewers ------------------>
  // ----------------------->

  // cache stories viewers
  @override
  Future<void> cacheStoryViewersList({required List<StoryViewer> storiesViewersList, required String boxKey}) async {
    // open box
    Box<StoryViewer> storiesViewersBox = Hive.box<StoryViewer>(StoryViewer.boxKey);
    // put viewers in the box
    for (var e in storiesViewersList) {
      storiesViewersBox.put(e.id, e);
    }
  }

  // get stories viewers from local storage
  @override
  List<StoryViewer>? getCachedStoryViewersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    Box<StoryViewer> storyViewersBox = Hive.box<StoryViewer>(StoryViewer.boxKey);
    List<StoryViewer> storyViewersList;
    int? startKey;
    int? endKey;

    if (storyViewersBox.isEmpty) {
      return null;
    } else {
      if (mediaId != null) {
        storyViewersList = storyViewersBox.values.where((element) => element.mediaId == mediaId).toList();

        if (pageKey != null && pageSize != null) {
          startKey = pageKey;
          endKey = startKey + pageSize;
          if (endKey > storyViewersList.length - 1) {
            endKey = storyViewersList.length;
          }
        }

        if (startKey != null && endKey != null && searchTerm == null) {
          // paginate
          storyViewersList = storyViewersList.sublist(startKey, endKey);
        } else if (searchTerm != null) {
          // search
          storyViewersList = storyViewersList.where((c) => c.user.username.toLowerCase().contains(searchTerm)).toList();
        }
      } else {
        storyViewersList = storyViewersBox.values.toList();
      }
      return storyViewersList;
    }
  }

  // ----------------------->
  // Media likers list ------------------>
  // ----------------------->
  // cache media likers list
  @override
  Future<void> cacheMediaLikersList({required List<MediaLiker> mediaLikersList, required String boxKey}) async {
    // open box
    Box<MediaLiker> mediaLikersBox = Hive.box<MediaLiker>(MediaLiker.boxKey);
    // put likers in the box
    for (var e in mediaLikersList) {
      mediaLikersBox.put(e.id, e);
    }
  }

  // get media likers list from local storage
  //TODO: to be uptimized (add limit and offset)
  @override
  List<MediaLiker>? getCachedMediaLikersList(
      {required String boxKey, String? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    Box<MediaLiker> mediaLikersBox = Hive.box<MediaLiker>(MediaLiker.boxKey);
    List<MediaLiker> mediaLikersList;

    if (mediaLikersBox.isEmpty) {
      return null;
    } else {
      // get mediaLikersList
      if (mediaId != null) {
        mediaLikersList = mediaLikersBox.values.where((element) => element.mediaId == mediaId).toList();
      } else {
        mediaLikersList = mediaLikersBox.values.toList();
      }

      // search
      if (searchTerm != null) {
        mediaLikersList = mediaLikersList.where((c) => c.user.username.toLowerCase().contains(searchTerm)).toList();
      }

      return mediaLikersList;
    }
  }

  // ----------------------->
  // Media commenters list ------------------>
  // ----------------------->
  // cache media commenters list
  @override
  Future<void> cacheMediaCommentersList(
      {required List<MediaCommenter> mediaCommentersList, required String boxKey}) async {
    // open box
    Box<MediaCommenter> mediaCommentersBox = Hive.box<MediaCommenter>(MediaCommenter.boxKey);
    // put commenters in the box
    for (var e in mediaCommentersList) {
      mediaCommentersBox.put(e.id, e);
    }
  }

  // get media commenters list from local storage
  @override
  List<MediaCommenter>? getCachedMediaCommentersList(
      {required String boxKey, int? mediaId, int? pageKey, int? pageSize, String? searchTerm}) {
    Box<MediaCommenter> mediaCommentersBox = Hive.box<MediaCommenter>(MediaCommenter.boxKey);
    List<MediaCommenter> mediaCommentersList;

    if (mediaCommentersBox.isEmpty) {
      return null;
    } else {
      // get mediaCommentersList
      if (mediaId != null) {
        mediaCommentersList = mediaCommentersBox.values.where((element) => element.mediaId == mediaId).toList();
      } else {
        mediaCommentersList = mediaCommentersBox.values.toList();
      }

      // search
      if (searchTerm != null) {
        mediaCommentersList =
            mediaCommentersList.where((c) => c.user.username.toLowerCase().contains(searchTerm)).toList();
      }

      return mediaCommentersList;
    }
  }

  // ----------------------->
  // WhoAdmiresYou Stats List ------------------>
  // ----------------------->
  // cache WhoAdmiresYou list
  @override
  Future<void> cacheWhoAdmiresYouList(
      {required List<LikesAndComments> whoAdmiresYouList, required String boxKey}) async {
    // open box
    Box<LikesAndComments> whoAdmiresYouBox = Hive.box<LikesAndComments>(boxKey);
    // put WhoAdmiresYou in the box
    for (var e in whoAdmiresYouList) {
      await whoAdmiresYouBox.put(e.user.username, e);
    }
  }

  // get WhoAdmiresYou from local storage
  @override
  List<LikesAndComments>? getCachedWhoAdmiresYouList(
      {required String boxKey, int? pageKey, int? pageSize, String? searchTerm}) {
    Box<LikesAndComments> whoAdmiresYouBox = Hive.box<LikesAndComments>(boxKey);
    List<LikesAndComments> whoAdmiresYouList;
    int? startKey;
    int? endKey;

    if (whoAdmiresYouBox.isEmpty) {
      return null;
    } else {
      whoAdmiresYouList = whoAdmiresYouBox.values.toList();

      if (pageKey != null && pageSize != null) {
        startKey = pageKey;
        endKey = startKey + pageSize;
        if (endKey > whoAdmiresYouList.length - 1) {
          endKey = whoAdmiresYouList.length;
        }
      }

      if (startKey != null && endKey != null && searchTerm == null) {
        // paginate
        whoAdmiresYouList = whoAdmiresYouList.sublist(startKey, endKey);
      }

      // search
      if (searchTerm != null) {
        whoAdmiresYouList = whoAdmiresYouList.where((c) => c.user.username.toLowerCase().contains(searchTerm)).toList();
      }

      return whoAdmiresYouList;
    }
  }

  // cache IgDataUpdate List
  @override
  Future<void> cacheIgDataUpdate({required IgDataUpdate igDataUpdate, required String boxKey}) async {
    // open box
    Box<IgDataUpdate> igDataUpdateBox = Hive.box<IgDataUpdate>(boxKey);
    // put IgDataUpdate in the box
    await igDataUpdateBox.put(igDataUpdate.dataName, igDataUpdate);
  }

  // get IgDataUpdate By name from local storage
  @override
  IgDataUpdate? getCachedIgDataUpdate({required String boxKey, required String dataName}) {
    Box<IgDataUpdate> igDataUpdateBox = Hive.box<IgDataUpdate>(boxKey);
    final IgDataUpdate igDataUpdateList;

    if (igDataUpdateBox.isEmpty) {
      return null;
    } else {
      igDataUpdateList = igDataUpdateBox.values.where((element) => element.dataName == dataName).first;

      return igDataUpdateList;
    }
  }

  // ----------------------->
  // Clear all boxes ------------------>
  // ----------------------->
  @override
  Future<void> clearAllBoxes() async {
    await Hive.box<Friend>(Friend.followersBoxKey).clear();
    await Hive.box<Friend>(Friend.followingsBoxKey).clear();
    await Hive.box<Friend>(Friend.newFollowersBoxKey).clear();
    await Hive.box<Friend>(Friend.lostFollowersBoxKey).clear();
    await Hive.box<Friend>(Friend.notFollowingBackBoxKey).clear();
    await Hive.box<Friend>(Friend.youDontFollowBackBoxKey).clear();
    await Hive.box<Friend>(Friend.mutualFollowingsBoxKey).clear();
    await Hive.box<Friend>(Friend.youHaveUnfollowedBoxKey).clear();
    await Hive.box<Friend>(Friend.newStoryViewersBoxKey).clear();

    await Hive.box<Report>(Report.boxKey).clear();
    await Hive.box<Media>(Media.boxKey).clear();
    await Hive.box<AccountInfo>(AccountInfo.boxKey).clear();
    await Hive.box<StoriesUser>(StoriesUser.boxKey).clear();
    await Hive.box<StoryViewer>(StoryViewer.boxKey).clear();
    await Hive.box<MediaLiker>(MediaLiker.boxKey).clear();
    await Hive.box<MediaCommenter>(MediaCommenter.boxKey).clear();
    await Hive.box<LikesAndComments>(LikesAndComments.boxKey).clear();
    await Hive.box<IgDataUpdate>(IgDataUpdate.boxKey).clear();
  }
}
