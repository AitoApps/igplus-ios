// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:igreports/data_source/source/headers_datasource.dart';
// import 'package:igreports/models/ig_headers.dart';

import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:igshark/data/models/account_info_model.dart';
import 'package:http/http.dart' as http;
import 'package:igshark/data/models/media_commenter_model.dart';
import 'package:igshark/data/models/media_model.dart';
import 'package:igshark/data/models/media_liker_model.dart';

import 'package:igshark/data/models/stories_user.dart';
import 'package:igshark/data/models/story_viewer_model.dart';

import 'package:igshark/domain/entities/friend.dart';
import 'package:igshark/domain/entities/stories_user.dart';
import 'package:igshark/domain/usecases/save_friends_to_local_use_case.dart';
import 'package:igshark/domain/usecases/update_story_by_id_use_case.dart';

import '../../constants.dart';
import '../../failure.dart';
import '../../models/friend_model.dart';
import '../../models/story_model.dart';

abstract class InstagramDataSource {
  Future<AccountInfoModel> getAccountInfoByUsername({required String username, required Map<String, String> headers});
  Future<AccountInfoModel> getAccountInfoById({required String igUserId, required Map<String, String> headers});
  Future<List<FriendModel>> getFollowers({
    required String igUserId,
    required Map<String, String> headers,
    String? maxIdString,
    required List<Friend> cachedFollowersList,
    required int newFollowersNumber,
  });
  Future<List<FriendModel>> getFollowings({required String igUserId, required Map<String, String> headers});
  Future<List<StoriesUserModel>> getUserStories({required Map<String, String> headers});
  Future<List<StoryModel?>> getStories({required String userId, required Map<String, String> headers});
  Future<bool> followUser({required String userId, required Map<String, String> headers});
  Future<bool> unfollowUser({required String userId, required Map<String, String> headers});
  Future<List<MediaModel>> getUserFeed({required String userId, required Map<String, String> headers});
  Future<List<StoryViewerModel>> getStoryViewers({required String mediaId, required Map<String, String> headers});
  Future<List<MediaLikerModel>> getMediaLikers({required String mediaId, required Map<String, String> headers});
  Future<List<MediaCommenterModel>> getMediaCommenters({required String mediaId, required Map<String, String> headers});
}

class InstagramDataSourceImp extends InstagramDataSource {
  final http.Client client;
  final CacheFriendsToLocalUseCase cacheFriendsToLocalUseCase;

  InstagramDataSourceImp({required this.client, required this.cacheFriendsToLocalUseCase});

  @override
  Future<AccountInfoModel> getAccountInfoById({required String igUserId, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getAccountInfoById(igUserId)), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['user']['is_private'] == null) {
        throw const InstagramSessionFailure("Instagram session expired");
      } else {
        return AccountInfoModel.fromJsonById(jsonResponse);
      }
    } else if (response.statusCode == 400) {
      // 400
      //{"message":"checkpoint_required","checkpoint_url":"https://i.instagram.com/challenge/?next=/api/v1/users/23689336944/info/","lock":true,"flow_render_type":0,"status":"fail"}
      throw const InstagramSessionFailure("checkpoint required");
    } else {
      // final jsonResponse = json.decode(response.body);
      // if (jsonResponse['message'].isNotEmpty) {
      //   throw InstagramSessionFailure(jsonResponse['message']);
      // } else {
      throw const InstagramSessionFailure("Instagram session expired");
      // }
    }
  }

  @override
  Future<AccountInfoModel> getAccountInfoByUsername(
      {required String username, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getAccountInfoByUsername(username)), headers: headers);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['user']['is_private'] == null) {
        throw const InstagramSessionFailure("Instagram session expired");
      } else {
        return AccountInfoModel.fromJsonByUsername(jsonResponse);
      }
    } else if (response.statusCode == 400) {
      // 400
      //{"message":"checkpoint_required","checkpoint_url":"https://i.instagram.com/challenge/?next=/api/v1/users/23689336944/info/","lock":true,"flow_render_type":0,"status":"fail"}
      throw const InstagramSessionFailure("checkpoint required");
    } else {
      throw const ServerFailure("Failed to get account info by username");
    }
  }

  @override
  Future<List<FriendModel>> getFollowers({
    required String igUserId,
    required Map<String, String> headers,
    String? maxIdString,
    required List<Friend> cachedFollowersList,
    required int newFollowersNumber,
  }) async {
    List<FriendModel> friendsList = [];
    String? nextMaxId = "";
    int nbrRequests = 1;
    const int requestsLimit = 20;

    final response =
        await client.get(Uri.parse(InstagramUrls.getFollowers(igUserId, maxIdString ?? "")), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      // search for last cached friend to get only new friends
      if (cachedFollowersList.isNotEmpty) {
        bool lastCachedFollowersDetected = false;
        int currentCase = 0;
        final List<dynamic> users = body['users'];
        nextMaxId = body['next_max_id'];
        List<FriendModel> friends = users.map((friend) => FriendModel.fromJson(friend)).toList();
        FriendModel lastFollowers = friends.last;

        int lastCachedFriendIndex =
            cachedFollowersList.indexWhere((element) => element.igUserId == lastFollowers.igUserId);
        List<Friend> tmpCachedFriendList = cachedFollowersList.sublist(0, lastCachedFriendIndex);

        // remove friends from cached list where igUserId is not in friends list (remove unfollowed)
        tmpCachedFriendList.removeWhere((element) => friends.indexWhere((e) => e.igUserId == element.igUserId) == -1);
        // save change to cached followers list
        cachedFollowersList = [...tmpCachedFriendList, ...cachedFollowersList.sublist(tmpCachedFriendList.length)];

        while (lastCachedFollowersDetected == false) {
          Friend lastCachedFriend = cachedFollowersList[currentCase];
          int lastCachedFriendIndex = friends.indexWhere((friend) => friend.igUserId == lastCachedFriend.igUserId);

          // test if last cached friends is still friend or no
          if (lastCachedFriendIndex != -1) {
            lastCachedFollowersDetected = true;
            if (lastCachedFriendIndex != 0) {
              // update friends list with new friends
              List<dynamic> newFriendsList = friends.sublist(0, lastCachedFriendIndex);
              friendsList = [
                ...newFriendsList,
                ...cachedFollowersList.map((friend) => FriendModel.fromFriend(friend)).toList()
              ];
            } else {
              // no changes keep using cached followers
              friendsList = cachedFollowersList.map((friend) => FriendModel.fromFriend(friend)).toList();
            }
          } else {
            if (friends.length < newFollowersNumber) {
              List<FriendModel> nextUsers =
                  await _loadAllFriends(nextMaxId, body, friendsList, nbrRequests, requestsLimit, igUserId, headers, 0);
              friends = [...nextUsers, ...users];
            } else {
              if (currentCase < cachedFollowersList.length - 1) {
                cachedFollowersList.removeAt(currentCase);
                currentCase++;
              } else {
                lastCachedFollowersDetected = true;
                friendsList = await _loadAllFriends(
                    nextMaxId, body, friendsList, nbrRequests, requestsLimit, igUserId, headers, 0);
              }
            }
          }
        }
      } else {
        friendsList =
            await _loadAllFriends(nextMaxId, body, friendsList, nbrRequests, requestsLimit, igUserId, headers, 0);
      }

      return friendsList;
    } else {
      throw const ServerFailure("Failed to get followers from Instagram");
    }
  }

  Future<List<FriendModel>> _loadAllFriends(String? nextMaxId, body, List<FriendModel> friendsList, int nbrRequests,
      int requestsLimit, String igUserId, Map<String, String> headers, int limit) async {
    nextMaxId = body['next_max_id'];
    List<dynamic> users = body["users"];
    friendsList = users.map((friend) => FriendModel.fromJson(friend)).toList();
    bool pagesLimit = (limit > 0) ? (friendsList.length < limit * 194) : true;

    while (nextMaxId != null && nbrRequests < requestsLimit && pagesLimit) {
      nbrRequests++;
      String maxIdString = "";
      if (nextMaxId != "") {
        await Future.delayed(const Duration(seconds: 3));
        nextMaxId = await _loadNextFollowersPage(maxIdString, nextMaxId, igUserId, headers, friendsList);
      } else {
        break;
      }
    }
    return friendsList;
  }

  Future<String?> _loadNextFollowersPage(String maxIdString, String? nextMaxId, String igUserId,
      Map<String, String> headers, List<FriendModel> friendsList) async {
    maxIdString = "&max_id=$nextMaxId";

    final response = await client.get(Uri.parse(InstagramUrls.getFollowers(igUserId, maxIdString)), headers: headers);

    final rs = jsonDecode(response.body);
    final List<dynamic> users = rs['users'] ?? [];

    if (users.isNotEmpty) {
      nextMaxId = rs['next_max_id'];
      final List<FriendModel> newFriendsList =
          users.map((f) => FriendModel.fromJson(f as Map<String, dynamic>)).toList();
      // // save new friends list to local
      // cacheFriendsToLocalUseCase.execute(
      //     boxKey: "followers", friendsList: newFriendsList.map((e) => e.toEntity()).toList());
      friendsList.addAll(newFriendsList);
    }
    return nextMaxId;
  }

  @override
  Future<List<FriendModel>> getFollowings(
      {required String igUserId, required Map<String, String> headers, String? maxIdString}) async {
    List<dynamic>? friendsList = [];
    String? nextMaxId = "";
    int nbrRequests = 1;
    const int requestsLimit = 20;

    final response =
        await client.get(Uri.parse(InstagramUrls.getFollowings(igUserId, maxIdString ?? "")), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      nextMaxId = body['next_max_id'];
      friendsList = body["users"] as List<dynamic>;

      while (nextMaxId != null && nbrRequests < requestsLimit) {
        nbrRequests++;
        String maxIdString = "";
        if (nextMaxId != "") {
          await Future.delayed(const Duration(seconds: 3));
          maxIdString = "&max_id=$nextMaxId";
          nextMaxId = null;

          final response =
              await client.get(Uri.parse(InstagramUrls.getFollowings(igUserId, maxIdString)), headers: headers);

          final rs = jsonDecode(response.body);

          if (rs['users'] != null) {
            nextMaxId = rs['next_max_id'];
            rs['users'].forEach((user) {
              friendsList?.add(user);
            });
          }
        } else {
          break;
        }
      }

      return friendsList.map((f) => FriendModel.fromJson(f as Map<String, dynamic>)).toList();
    } else {
      throw const ServerFailure("Failed to get followers from Instagram");
    }
  }

  // get active stories from peaple you follow
  @override
  Future<List<StoriesUserModel>> getUserStories({required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getUserStories()), headers: headers);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)["tray"] as List<dynamic>;
      return result.map((story) => StoriesUserModel.fromJson(story as Map<String, dynamic>)).toList();
    } else {
      throw const ServerFailure("Failed to get active stories from Instagram");
    }
  }

  @override
  Future<List<StoryModel?>> getStories({required String userId, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getStories(userId: userId)), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["reels_media"].isEmpty) {
        return [];
      }
      final result = body["reels_media"][0]['items'] as List<dynamic>;
      final storiesList = result.map((story) => StoryModel.fromJson(story as Map<String, dynamic>)).toList();
      return storiesList;
    } else {
      throw const ServerFailure("Failed to get active stories from Instagram");
    }
  }

  // follow user
  @override
  Future<bool> followUser({required String userId, required Map<String, String> headers}) async {
    final response = await client.post(Uri.parse(InstagramUrls.followUser(userId)), headers: headers);

    if (response.statusCode == 200 && response.body.contains('"status":"ok"')) {
      return true;
    } else if (response.statusCode == 302 && response.body == "") {
      return true;
    } else if (response.body.contains("The link you followed may be broken, or the page may have been removed.")) {
      throw const ServerFailure("User not found");
    } else {
      throw const ServerFailure("Failed to follow user");
    }
  }

  // unfollow user
  @override
  Future<bool> unfollowUser({required String userId, required Map<String, String> headers}) async {
    final response = await client.post(Uri.parse(InstagramUrls.unfollowUser(userId.toString())), headers: headers);
    if (response.statusCode == 200 && response.body.contains('"status":"ok"')) {
      return true;
    } else if (response.statusCode == 302 && response.body == "") {
      return true;
    } else if (response.body.contains("The link you followed may be broken, or the page may have been removed.")) {
      throw const ServerFailure("User not found");
    } else {
      throw const ServerFailure("Failed to follow user");
    }
  }

  // user feed media
  @override
  Future<List<MediaModel>> getUserFeed({required String userId, required Map<String, String> headers}) async {
    headers['User-Agent'] = "Instagram 219.0.0.12.117 Android";
    final response = await client.get(Uri.parse(InstagramUrls.getUserFeed(userId)), headers: headers);

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body)["items"] as List<dynamic>;
      return result.map((friend) => MediaModel.fromJson(friend as Map<String, dynamic>)).toList();
    } else {
      throw const ServerFailure("Failed to get besties from Instagram");
    }
  }

  // story viewers list
  @override
  Future<List<StoryViewerModel>> getStoryViewers(
      {required String mediaId, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getStoriesViewersList(mediaId, "")), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final viewers = body["viewers"] as List<dynamic>;
      List<StoryViewerModel> storyViewers =
          viewers.map((viewer) => StoryViewerModel.fromJson(viewer as Map<String, dynamic>, mediaId)).toList();
      String? nextMaxId = body['next_max_id'];
      while (nextMaxId != null) {
        await Future.delayed(const Duration(seconds: 3));
        nextMaxId = await _loadNextStoryViewersPage(nextMaxId, mediaId, headers, storyViewers);
      }
      return storyViewers;
    } else {
      throw const ServerFailure("Failed to get story viewers from Instagram");
    }
  }

  Future<String?> _loadNextStoryViewersPage(
      String? nextMaxId, String mediaId, Map<String, String> headers, List<StoryViewerModel> storyViewers) async {
    String maxIdString = "?max_id=$nextMaxId";

    final response =
        await client.get(Uri.parse(InstagramUrls.getStoriesViewersList(mediaId, maxIdString)), headers: headers);

    final body = jsonDecode(response.body);
    final viewers = body["viewers"] as List<dynamic>;

    if (viewers.isNotEmpty) {
      nextMaxId = body['next_max_id'];
      final List<StoryViewerModel> newStoryViewers =
          viewers.map((f) => StoryViewerModel.fromJson(f as Map<String, dynamic>, mediaId)).toList();
      storyViewers.addAll(newStoryViewers);
    }
    return nextMaxId;
  }

  // get media likers list
  @override
  Future<List<MediaLikerModel>> getMediaLikers({required String mediaId, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getMediaLikersList(mediaId, "")), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final usersJson = body["users"] as List<dynamic>;
      List<MediaLikerModel> mediaLikers =
          usersJson.map((userJson) => MediaLikerModel.fromJson(userJson as Map<String, dynamic>, mediaId)).toList();
      String? nextMaxId = body['next_max_id'];
      while (nextMaxId != null) {
        await Future.delayed(const Duration(seconds: 3));
        nextMaxId = await _loadNextPostLikersPage(nextMaxId, mediaId, headers, mediaLikers);
      }
      return mediaLikers;
    } else if (response.statusCode == 400) {
      throw const ServerFailure("Media not found");
    } else if (response.statusCode == 429) {
      throw const ServerFailure("Too Many Requests");
    } else {
      throw const ServerFailure("Failed to get media likers from Instagram");
    }
  }

  Future<String?> _loadNextPostLikersPage(
      String? nextMaxId, String mediaId, Map<String, String> headers, List<MediaLikerModel> mediaLikers) async {
    String maxIdString = "?max_id=$nextMaxId";

    final response =
        await client.get(Uri.parse(InstagramUrls.getMediaLikersList(mediaId, maxIdString)), headers: headers);

    final body = jsonDecode(response.body);
    final usersJson = body["users"] as List<dynamic>;
    if (usersJson.isNotEmpty) {
      nextMaxId = body['next_max_id'];
      final List<MediaLikerModel> newPostLikers =
          usersJson.map((u) => MediaLikerModel.fromJson(u as Map<String, dynamic>, mediaId)).toList();
      mediaLikers.addAll(newPostLikers);
    }
    return nextMaxId;
  }

  // get media commenters list
  @override
  Future<List<MediaCommenterModel>> getMediaCommenters(
      {required String mediaId, required Map<String, String> headers}) async {
    final response = await client.get(Uri.parse(InstagramUrls.getMediaCommentersList(mediaId, "")), headers: headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final comments = body["comments"] as List<dynamic>;
      List<MediaCommenterModel> mediaCommenters =
          comments.map((comment) => MediaCommenterModel.fromJson(comment as Map<String, dynamic>, mediaId)).toList();
      String? nextMaxId = body['next_max_id'];
      while (nextMaxId != null) {
        await Future.delayed(const Duration(seconds: 3));
        nextMaxId = await _loadNextPostCommentersPage(nextMaxId, mediaId, headers, mediaCommenters);
      }
      return mediaCommenters;
    } else if (response.statusCode == 400) {
      throw const ServerFailure("Media not found");
    } else {
      throw const ServerFailure("Failed to get media commenters from Instagram");
    }
  }

  Future<String?> _loadNextPostCommentersPage(
      String? nextMaxId, String mediaId, Map<String, String> headers, List<MediaCommenterModel> mediaCommenters) async {
    String maxIdString = "?max_id=$nextMaxId";

    final response =
        await client.get(Uri.parse(InstagramUrls.getMediaLikersList(mediaId, maxIdString)), headers: headers);

    final body = jsonDecode(response.body);
    final usersJson = body["users"] as List<dynamic>;
    if (usersJson.isNotEmpty) {
      nextMaxId = body['next_max_id'];
      final List<MediaCommenterModel> newPostLikers =
          usersJson.map((u) => MediaCommenterModel.fromJson(u as Map<String, dynamic>, mediaId)).toList();
      mediaCommenters.addAll(newPostLikers);
    }
    return nextMaxId;
  }
}

// get viewers of a my stories
//https://i.instagram.com/api/v1/feed/user/{user_id}/reel_media/

// get stories
//https://i.instagram.com/api/v1/feed/reels_tray/

// //https://github.com/postaddictme/instagram-php-scraper
// class InstagramDataSource {
//   const InstagramDataSource({required this.headersDataSource});
//   final HeadersDataSource headersDataSource;

//   //final  BaseUrl = "https://i.instagram.com/api/v1";

//   Future<http.Response> getUserInfo({required String igUserId, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/users/$igUserId/info');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

//   //https://www.instagram.com/$username/?__a=1
//   Future<http.Response> getUserInfoByUsername({required String username, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/users/web_profile_info/?username=$username');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

//   //1-https://i.instagram.com/api/v1/media/2445116530512128408/info
//   //2-https://www.instagram.com/p/{code}/?__a=1
//   // we use the seconde url
//   Future<http.Response> getMediaInfoByUrl({required Uri uri, required IgHeaders igHeaders}) async {
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

//   Future<http.Response> getUserStories({required String igUserId, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/feed/reels_media/?reel_ids=$igUserId');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

//   // https://i.instagram.com/api/v1/friendships/show/4280661977
//   Future<http.Response> getFriendshipStatus({required String friendIgUserId, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/friendships/show/$friendIgUserId');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

// //https://i.instagram.com/api/v1/feed/user/47092259342/story/
//   Future<http.Response> getStories({required String IgUserId, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/feed/user/$IgUserId/story/');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

//   //https://www.instagram.com/graphql/query/?query_hash=e769aa130647d2354c40ea6a439bfc08&variables={variables}
//   Future<http.Response> getUserMedias({required String username, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/users/web_profile_info/?username=$username');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;
//   }

// // https://i.instagram.com/api/v1/tags/search/?q=tiktok
//   Future<http.Response> getHashtagsRelatedTo({required String keyword, required IgHeaders igHeaders}) async {
//     final uri = Uri.parse('https://i.instagram.com/api/v1/tags/search/?q=$keyword');
//     http.Response response = await http.get(uri, headers: igHeaders.toJson());
//     return response;

//     // const mainHost = 'www.instagram.com';
//     // const mainHost = 'i.instagram.com';
//     // var queryParameters = {
//     //   'context': 'hashtag',
//     //   'query': keyword,
//     //   //'verifyFp': verifyFp,
//     //   //'user_agent': headers['user-agent'],
//     // };
//     // // var uri = Uri.https(mainHost, '/web/search/topsearch/', queryParameters);

//     // http.Response response = await http.get(uri, headers: igHeaders.toJson());

//     // return response;
//   }
// }

// //https://i.instagram.com/api/v1/feed/timeline
