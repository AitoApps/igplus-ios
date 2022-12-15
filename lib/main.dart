import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:igshark/app/app.dart';
import 'package:igshark/app/bloc/app_bloc.dart';
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
import 'package:igshark/presentation/blocs/engagement/cubit/engagement_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_commeters/cubit/media_commenters_cubit.dart';
import 'package:igshark/presentation/blocs/engagement/media_likers/cubit/media_likers_cubit.dart';
import 'package:igshark/presentation/blocs/friends_list/cubit/friends_list_cubit.dart';
import 'package:igshark/presentation/blocs/home/report/cubit/report_cubit.dart';
import 'package:igshark/presentation/blocs/insight/cubit/insight_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/cubit/stories_insight_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/story_viewers/cubit/story_viewers_cubit.dart';
import 'package:igshark/presentation/blocs/insight/stories_insight/story_viewers/story_download/cubit/story_download_cubit.dart';
import 'package:igshark/presentation/blocs/login/cubit/instagram_auth_cubit.dart';
import 'package:igshark/presentation/blocs/insight/media_insight/cubit/media_list_cubit.dart';
import 'package:igshark/presentation/blocs/home/stories/cubit/stories_cubit.dart';
import 'package:igshark/presentation/blocs/home/user_stories/cubit/user_stories_cubit.dart';
import 'package:igshark/presentation/blocs/paywall/cubit/paywall_cubit.dart';
import 'package:igshark/presentation/blocs/paywall/subscription/cubit/subscription_cubit.dart';
import 'package:igshark/presentation/blocs/settings/cubit/settings_cubit.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'app/bloc_observer.dart';
import 'app/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseAuth.instance.signInAnonymously();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(FriendAdapter());
  Hive.registerAdapter(ReportAdapter());
  Hive.registerAdapter(ChartDataAdapter());
  Hive.registerAdapter(MediaAdapter());
  Hive.registerAdapter(AccountInfoAdapter());
  Hive.registerAdapter(StoryAdapter());
  Hive.registerAdapter(StoryOwnerAdapter());
  Hive.registerAdapter(StoriesUserAdapter());
  Hive.registerAdapter(StoryViewerAdapter());
  Hive.registerAdapter(MediaLikerAdapter());
  Hive.registerAdapter(MediaCommenterAdapter());
  Hive.registerAdapter(LikesAndCommentsAdapter());
  Hive.registerAdapter(IgDataUpdateAdapter());

  // loading the <key,values> pair from the local storage into memory
  try {
    // friends boxes
    await Hive.openBox<Friend>(Friend.followersBoxKey);
    await Hive.openBox<Friend>(Friend.followingsBoxKey);
    await Hive.openBox<Friend>(Friend.newFollowersBoxKey);
    await Hive.openBox<Friend>(Friend.lostFollowersBoxKey);
    await Hive.openBox<Friend>(Friend.notFollowingBackBoxKey);
    await Hive.openBox<Friend>(Friend.youDontFollowBackBoxKey);
    await Hive.openBox<Friend>(Friend.youHaveUnfollowedBoxKey);
    await Hive.openBox<Friend>(Friend.mutualFollowingsBoxKey);
    await Hive.openBox<Friend>(Friend.newStoryViewersBoxKey);
    // report box
    await Hive.openBox<Report>(Report.boxKey);
    // media box
    await Hive.openBox<Media>(Media.boxKey);
    // account info box
    await Hive.openBox<AccountInfo>(AccountInfo.boxKey);
    // stories user
    await Hive.openBox<StoriesUser>(StoriesUser.boxKey);
    // stories viewers box
    await Hive.openBox<StoryViewer>(StoryViewer.boxKey);
    // media likers box
    await Hive.openBox<MediaLiker>(MediaLiker.boxKey);
    // media commenters box
    await Hive.openBox<MediaCommenter>(MediaCommenter.boxKey);
    // who admires you box
    await Hive.openBox<LikesAndComments>(LikesAndComments.boxKey);
    // IgDataUpdate box
    await Hive.openBox<IgDataUpdate>(IgDataUpdate.boxKey);
  } catch (e) {
    debugPrint(e.toString());
  }

  // inapp purchase configuration
  // revenuecat
  final String apiKey;
  if (Platform.isAndroid) {
    // apiKey Android
    apiKey = "goog_jTbejulNISJfiKvxEfNvzVqpAUY";
  } else {
    // apiKey IOS
    apiKey = "appl_QivdadMnvjMBVqgSUzWqhEoYSlL";
  }

  await Purchases.configure(PurchasesConfiguration(apiKey));

  await di.init();
  Bloc.observer = AppBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<InstagramAuthCubit>(
          create: (_) => di.sl<InstagramAuthCubit>(),
        ),
        BlocProvider<ReportCubit>(create: (_) => di.sl<ReportCubit>()),
        BlocProvider<FriendsListCubit>(create: (_) => di.sl<FriendsListCubit>()),
        BlocProvider<MediaListCubit>(create: (_) => di.sl<MediaListCubit>()),
        BlocProvider<UserStoriesCubit>(create: (_) => di.sl<UserStoriesCubit>()),
        BlocProvider<StoriesCubit>(create: (_) => di.sl<StoriesCubit>()),
        BlocProvider<StoriesInsightCubit>(create: (_) => di.sl<StoriesInsightCubit>()),
        BlocProvider<StoryViewersCubit>(create: (_) => di.sl<StoryViewersCubit>()),
        BlocProvider<MediaLikersCubit>(create: (_) => di.sl<MediaLikersCubit>()),
        BlocProvider<MediaCommentersCubit>(create: (_) => di.sl<MediaCommentersCubit>()),
        BlocProvider<SubscriptionCubit>(create: (_) => di.sl<SubscriptionCubit>()),
        BlocProvider<PaywallCubit>(create: (_) => di.sl<PaywallCubit>()),
        BlocProvider<EngagementCubit>(create: (_) => di.sl<EngagementCubit>()),
        BlocProvider<InsightCubit>(create: (_) => di.sl<InsightCubit>()),
        BlocProvider<SettingsCubit>(create: (_) => di.sl<SettingsCubit>()),
        BlocProvider<AppBloc>(create: (_) => di.sl<AppBloc>()),
        BlocProvider<StoryDownloadCubit>(create: (_) => di.sl<StoryDownloadCubit>()),
      ],
      child: const App(),
    ),
  );
}
