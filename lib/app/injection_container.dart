import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:igshark/app/bloc/app_bloc.dart';
import 'package:igshark/data/models/stories_user.dart';
import 'package:igshark/data/repositories/local/local_repository_imp.dart';
import 'package:igshark/data/sources/local/local_datasource.dart';
import 'package:igshark/domain/repositories/auth/auth_repository.dart';
import 'package:igshark/domain/repositories/firebase/firebase_repository.dart';
import 'package:igshark/domain/repositories/firebase/headers_repository.dart';
import 'package:igshark/domain/repositories/instagram/instagram_repository.dart';
import 'package:igshark/domain/repositories/local/local_repository.dart';
import 'package:igshark/domain/usecases/add_friends_to_local_use_case.dart';
import 'package:igshark/domain/usecases/clear_local_data_use_case.dart';
import 'package:igshark/domain/usecases/follow_user_use_case.dart';
import 'package:igshark/domain/usecases/get_account_info_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_commenters_use_case.dart';
import 'package:igshark/domain/usecases/get_media_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_media_likers_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_users_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_story_viewers_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_story_viewers_use_case.dart';
import 'package:igshark/domain/usecases/get_user_feed_use_case.dart';
import 'package:igshark/domain/usecases/get_friends_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_report_from_local_use_case.dart';
import 'package:igshark/domain/usecases/get_stories_users_use_case.dart';
import 'package:igshark/domain/usecases/get_who_admires_you_from_local_use_case.dart';
import 'package:igshark/domain/usecases/remove_friends_from_local_use_case%20copy.dart';
import 'package:igshark/domain/usecases/save_account_info_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_friends_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_media_commenters_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_media_likers_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_media_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_stories_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_stories_user_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_story_viewers_to_local_use_case.dart';
import 'package:igshark/domain/usecases/save_ig_data_update_use_case.dart';
import 'package:igshark/domain/usecases/sign_up_with_cstom_token_use_case.dart';
import 'package:igshark/domain/usecases/unfollow_user_use_case%20copy.dart';
import 'package:igshark/domain/usecases/update_report_use_case.dart';
import 'package:igshark/domain/usecases/update_story_by_id_use_case.dart';
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_commeters/cubit/media_commenters_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/blocs/home/stories/cubit/stories_cubit.dart';
import 'package:igshark/presentation/blocs/home/user_stories/cubit/user_stories_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/cubit/stories_insight_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/story_viewers/cubit/story_viewers_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/story_viewers/story_download/cubit/story_download_cubit.dart';
import 'package:igshark/presentation/blocs/paywall/cubit/paywall_cubit.dart';
import 'package:igshark/presentation/blocs/paywall/subscription/cubit/subscription_cubit.dart';
import 'package:igshark/presentation/blocs/settings/cubit/settings_cubit.dart';
import '../data/models/story_model.dart';
import '../data/repositories/firebase/firebase_repository_imp.dart';
import '../data/repositories/firebase/headers_repository_imp.dart';
import '../data/repositories/instagram/instagram_repository_imp.dart';
import '../data/sources/firebase/firebase_data_source.dart';
import '../domain/usecases/authorize_user.dart';
import '../domain/usecases/get_headers_use_case.dart';
import '../domain/usecases/get_stories_use_case.dart';
import '../presentation/blocs/login/cubit/instagram_auth_cubit.dart';
import '../data/sources/instagram/instagram_data_source.dart';
import '../domain/usecases/creat_user_use_case.dart';
import '../domain/usecases/get_account_info_use_case.dart';
import '../domain/usecases/get_user_use_case.dart';
import '../domain/usecases/update_user_use_case.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => InstagramAuthCubit(
        getAccountInfo: sl(),
        getHeaders: sl(),
        authorizeUser: sl(),
        createUser: sl(),
        updateUser: sl(),
        getUser: sl(),
        signUpWithCustomToken: sl(),
      ));

  sl.registerFactory(() => ReportCubit(
        updateReport: sl(),
        getUser: sl(),
        getAccountInfo: sl(),
        getDataFromLocal: sl(),
        getReportFromLocal: sl(),
        getUserFeed: sl(),
        cacheMediaToLocal: sl(),
        getAccountInfoFromLocalUseCase: sl(),
        cacheAccountInfoToLocalUseCase: sl(),
        clearAllBoxesUseCase: sl(),
        authRepository: sl(),
        getWhoAdmiresYouFromLocalUseCase: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));

  sl.registerFactory(() => FriendsListCubit(
        getFriendsFromLocal: sl(),
        followUserUseCase: sl(),
        getUser: sl(),
        unfollowUserUseCase: sl(),
        addFriendToLocal: sl(),
        removeFriendFromLocal: sl(),
      ));
  sl.registerFactory(() => UserStoriesCubit(
        getUserStories: sl(),
        getUser: sl(),
        getStoriesUsersFromLocal: sl(),
        cacheStoriesUsersToLocal: sl(),
        cacheStoriesToLocal: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => StoriesCubit(
        getStories: sl(),
        getUser: sl(),
        getStoriesFromLocal: sl(),
        cacheStoriesToLocal: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => MediaListCubit(
        getMediaFromLocal: sl(),
        getUser: sl(),
        cacheMediaToLocal: sl(),
        getUserFeed: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => StoriesInsightCubit(
        getStoriesFromLocal: sl(),
        getUserFeed: sl(),
        getUser: sl(),
        cacheStoriesToLocal: sl(),
        getStoriesUseCase: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => StoryViewersCubit(
        getStoryViewersFromLocal: sl(),
        getStoryViewers: sl(),
        followUserUseCase: sl(),
        getUser: sl(),
        unfollowUserUseCase: sl(),
        cacheStoryViewersToLocalUseCase: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => MediaLikersCubit(
        getMediaLikersUseCase: sl(),
        getUser: sl(),
        getMediaFromLocalUseCase: sl(),
        cacheMediaLikersToLocalUseCase: sl(),
        getMediaLikersFromLocalUseCase: sl(),
        getFriendsFromLocalUseCase: sl(),
        getUserFeed: sl(),
        cacheMediaToLocal: sl(),
        getWhoAdmiresYouFromLocalUseCase: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => AppBloc(authRepository: sl()));
  sl.registerFactory(() => MediaCommentersCubit(
        getUser: sl(),
        getMediaFromLocalUseCase: sl(),
        getFriendsFromLocalUseCase: sl(),
        getMediaCommentersUseCase: sl(),
        cacheMediaCommentersToLocalUseCase: sl(),
        getMediaCommentersFromLocalUseCase: sl(),
        getIgDataUpdateUseCase: sl(),
        saveIgDataUpdateUseCase: sl(),
      ));
  sl.registerFactory(() => SubscriptionCubit());
  sl.registerFactory(() => PaywallCubit(getAccountInfoFromLocalUseCase: sl()));
  sl.registerFactory(() => EngagementCubit());
  sl.registerFactory(() => SettingsCubit(
        getAccountInfoFromLocalUseCase: sl(),
        clearAllBoxesUseCase: sl(),
      ));

  sl.registerFactory(() => StoryDownloadCubit());

  // Use cases
  sl.registerLazySingleton(() => GetAccountInfoUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => GetHeadersUseCase(headersRepository: sl()));
  sl.registerLazySingleton(() => AuthorizeUser(firebaseRepository: sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(instagramRepository: sl(), firebaseRepository: sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(instagramRepository: sl(), firebaseRepository: sl()));
  sl.registerLazySingleton(() => GetUserUseCase(firebaseRepository: sl()));
  sl.registerLazySingleton(() => GetFriendsFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => UpdateReportUseCase(
        instagramRepository: sl(),
        localRepository: sl(),
        getMediaLikersFromLocalUseCase: sl(),
        getMediaCommentersFromLocalUseCase: sl(),
        getFriendsFromLocalUseCase: sl(),
      ));
  sl.registerLazySingleton(() => GetStoriesUsersUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => GetReportFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetStoriesUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => SignUpWithCustomTokenUseCase(sl()));
  sl.registerLazySingleton(() => FollowUserUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => UnfollowUserUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => GetUserFeedUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => CacheMediaToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetMediaFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => CacheFriendsToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetAccountInfoFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => CacheAccountInfoToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => ClearAllBoxesUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => CacheStoriesToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetStoriesFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => CacheStoriesUserToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetStoriesUsersFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetStoryViewersUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => GetStoryViewersFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => UpdateStoryByIdUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => CacheStoryViewersToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetMediaLikersUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => CacheMediaLikersToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetMediaLikersFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetMediaCommentersUseCase(instagramRepository: sl()));
  sl.registerLazySingleton(() => CacheMediaCommentersToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetMediaCommentersFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetWhoAdmiresYouFromLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => GetIgDataUpdateUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => SaveIgDataUpdateUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => AddFriendToLocalUseCase(localRepository: sl()));
  sl.registerLazySingleton(() => RemoveFriendFromLocalUseCase(localRepository: sl()));

  // Repositories
  sl.registerLazySingleton<FirebaseRepository>(() => FirebaseRepositporyImp(firebaseDataSource: sl()));
  sl.registerLazySingleton<InstagramRepository>(
      () => InstagramRepositoryImp(instagramDataSource: sl(), storyUserMapper: sl(), storyMapper: sl()));
  sl.registerLazySingleton<LocalRepository>(() => LocalRepositoryImpl(localDataSource: sl()));
  sl.registerLazySingleton<HeadersRepository>(() => HeadersRepositoryImp(firebaseDataSource: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImp(firebaseDataSource: sl()));

  // Data sources
  sl.registerLazySingleton<FirebaseDataSource>(
      () => FirebaseDataSourceImp(client: sl(), firebaseAuth: sl(), firebaseFirestore: sl()));
  sl.registerLazySingleton<InstagramDataSource>(
      () => InstagramDataSourceImp(client: sl(), cacheFriendsToLocalUseCase: sl()));
  sl.registerLazySingleton<LocalDataSource>(() => LocalDataSourceImp(client: sl()));

  // Data Mapper
  sl.registerLazySingleton<UserStoryMapper>(() => UserStoryMapper());
  sl.registerLazySingleton<StoryMapper>(() => StoryMapper());

  // External
  final client = http.Client();
  final firebaseFirestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance;
  sl.registerLazySingleton(() => client);
  sl.registerLazySingleton(() => firebaseFirestore);
  sl.registerLazySingleton(() => firebaseAuth);
}
