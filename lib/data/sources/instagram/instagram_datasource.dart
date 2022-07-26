// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:igreports/data_source/source/headers_datasource.dart';
// import 'package:igreports/models/ig_headers.dart';

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